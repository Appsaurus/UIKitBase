//
//  BaseParentPageViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Foundation
import Layman
import Swiftest
import UIKit

extension BaseParentPagingViewController:
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    AsyncDatasourceChangeManager
{}

open class BaseParentPagingViewController: BaseParentViewController {
    open lazy var eagerLoadBuffer: Int? = nil
    open lazy var initialPageIndex: Int = 0
    open var loadsPagesImmediately: Bool = true
    open var showsPageControl: Bool = false
    open lazy var customPageControl = UIPageControl().then {
        $0.isUserInteractionEnabled = false
    }

    public func defaultReloadIndex() -> Int {
        return self.currentPage ?? self.initialPageIndex
    }

    // AsyncStateManagementQueue
    open var asyncDatasourceChangeQueue: [AsyncDatasourceChange] = []
    open var uponQueueCompletion: VoidClosure?

    open lazy var pageViewController: BasePageViewController = self.createPageViewController()

    open var animatesPageTransitions: Bool {
        return false
    }

    open func createPageViewController() -> BasePageViewController {
        let pageVC = BasePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pageVC
    }

    override open func initialChildViewController() -> UIViewController {
        return self.pageViewController
    }

    open lazy var pagedViewControllers: [UIViewController] = {
        self.createPagedViewControllers()
    }()

    open func createPagedViewControllers() -> [UIViewController] {
        return []
    }

    open var currentPagedViewController: UIViewController? {
        return self.pageViewController.viewControllers?.first
    }

    open var currentPage: Int? {
        didSet {
            DispatchQueue.main.async {
                if let currentPage = self.currentPage { self.customPageControl.currentPage = currentPage }
            }
        }
    }

    open var pendingPage: Int?

    override open func setupDelegates() {
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
    }

    override open func style() {
        super.style()
        self.customPageControl.pageIndicatorTintColor = .deselected
        self.customPageControl.currentPageIndicatorTintColor = .primaryLight
    }

    override open func createSubviews() {
        super.createSubviews()
        self.pageViewController.hidePageControl() // Hide default page control
        guard self.showsPageControl else {
            return
        }
        view.addSubview(self.customPageControl)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.layoutPageControl()
    }

    open func layoutPageControl() {
        guard self.showsPageControl else {
            return
        }
        self.customPageControl.enforceContentSize()
//        pageControl.height.equal(to: 30)
//        pageControl.width.equal(to: self.view.width.times(0.5))
        self.customPageControl.centerX.equal(to: view.centerX)
        self.customPageControl.bottom.equal(to: bottom.inset(20))
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.showsPageControl else {
            return
        }
        self.customPageControl.moveToFront()
    }

    override open func didTransition(to state: State) {
        super.didTransition(to: state)
        guard state == .empty else { return }
        self.pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
    }

    open func transitionToPage(at index: Int) {
        guard index >= 0, index < self.pagedViewControllers.count else {
            transition(to: .empty)
            return
        }

        guard index != self.currentPage else {
            return
        }
        guard isViewLoaded else {
            self.initialPageIndex = index
            return
        }
//        transition(to: .loading)
        let page = self.currentPage
        self.willPage(from: page, to: index)
        self._performTransitionToPage(at: index)
        self.didPage(from: page, to: index)
    }

    open func willPage(from page: Int?, to nextPage: Int?) {
        self.pendingPage = nextPage
    }

    open func didCancelPaging(from page: Int?, to nextPage: Int?) {
        self.pendingPage = nil
    }

    var isTransitioningPage: Bool = false

    private func _performTransitionToPage(at index: Int) {
        guard !self.isTransitioningPage else { return }
        self.currentPagedViewController?.view.endEditing(true)
        let vc = self.pagedViewControllers[index]
        let direction: UIPageViewController.NavigationDirection = index > self.currentPage ?? 0 ? .forward : .reverse
        if let eagerLoadBuffer = eagerLoadBuffer {
            self.eagerLoadViewControllers(surrounding: index, by: eagerLoadBuffer)
        }
        self.isTransitioningPage = true
        self.pageViewController.setViewControllers([vc], direction: direction, animated: self.animatesPageTransitions, completion: { [weak self] _ in
            self?.isTransitioningPage = false
            self?.currentPage = index
        })
    }

    open func didPage(from page: Int?, to nextPage: Int?) {
//        print("Did page from: \(page) to: \(nextPage)")
        self.currentPage = nextPage
        self.pendingPage = nil
    }

    open func eagerLoadViewControllers(surrounding index: Int, by buffer: Int) {
        let minIndex = 0
        let maxIndex = self.pagedViewControllers.lastIndex
        let startIndex = buffer == .max ? minIndex : max(index - buffer, minIndex)
        let lastIndex = buffer == .max ? maxIndex : min(index + buffer, maxIndex)
        guard startIndex < lastIndex else { return }
        for vc in self.pagedViewControllers[startIndex ... lastIndex] {
            vc.loadViewIfNeeded()
        }
    }

    open func transitionToPage(of viewController: UIViewController) {
        guard let index = pagedViewControllers.firstIndex(of: viewController) else {
            debugLog("Attempted to page to vc not in page index")
            return
        }
        self.transitionToPage(at: index)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if self.loadsPagesImmediately { self.reloadPages() }
    }

    open func pageViewController(_ pageViewController: UIPageViewController,
                                 viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pagedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard self.pagedViewControllers.count > previousIndex else {
            return nil
        }

        return self.pagedViewControllers[previousIndex]
    }

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pagedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.pagedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return self.pagedViewControllers[nextIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        guard let lastVC = self.pageViewController.viewControllers?.last else { return }

        guard finished else { return }

        guard completed else {
            self.didCancelPaging(from: self.currentPage, to: self.pendingPage)
            return
        }
        let newIndex = self.pagedViewControllers.firstIndex(of: lastVC)
        self.didPage(from: self.currentPage, to: newIndex)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let lastVC = pendingViewControllers.last else { return }
        self.willPage(from: self.currentPage, to: self.pagedViewControllers.firstIndex(of: lastVC))
    }

    open func reloadPageDatasource() {
        self.pagedViewControllers = self.createPagedViewControllers()
        self.currentPage = nil
    }

    open func reloadPages(initialPage: Int? = nil) {
        let index = initialPage ?? self.defaultReloadIndex()
        enqueue { complete in
            self.reloadPageDatasource()
            if self.pagedViewControllers.count > 0 {
                self.transitionToPage(at: index)
            } else {
                self.transition(to: .empty)
            }
            self.pagesDidReload()
            complete()
        }
    }

    open func pagesDidReload() {
        self.customPageControl.numberOfPages = self.pagedViewControllers.count
        self.customPageControl.currentPage = self.currentPage ?? 0
        //		transitionToPage(at: defaultReloadIndex())
    }

//    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return self.pagedViewControllers.count
//    }
//
//    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return self.pagedViewControllers.index(of: pageViewController) ?? 0
//    }
}
