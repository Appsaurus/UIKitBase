//
//  BaseParentPageViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Foundation
import Swiftest
import UIKit
import Layman

extension BaseParentPagingViewController:
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    AsyncDatasourceChangeManager
{}
open class BaseParentPagingViewController: BaseParentViewController {
    open lazy var eagerLoadBuffer: Int? = nil
    open lazy var initialPageIndex: Int = 0
    open var loadsPagesImmediately: Bool = true

    public func defaultReloadIndex() -> Int {
        return currentPage ?? initialPageIndex
    }

    // AsyncStateManagementQueue
    open var asyncDatasourceChangeQueue: [AsyncDatasourceChange] = []
    open var uponQueueCompletion: VoidClosure?

    open lazy var pageControl = UIPageControl().then{
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
    }

    open lazy var pageViewController: BasePageViewController = self.createPageViewController()

    open var animatesPageTransitions: Bool {
        return false
    }

    open func createPageViewController() -> BasePageViewController {
        let pageVC = BasePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pageVC
    }

    open override func initialChildViewController() -> UIViewController {
        return pageViewController
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
                if let currentPage = self.currentPage { self.pageControl.currentPage = currentPage }
            }
        }
    }
    open var pendingPage: Int?

    open override func setupDelegates(){
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }

    open override func style() {
        super.style()
        self.pageControl.pageIndicatorTintColor = .deselected
        self.pageControl.currentPageIndicatorTintColor = .primaryLight
//        self.pageControl.apply(viewStyle: .card)
    }
    open override func createSubviews() {
        super.createSubviews()
        view.addSubview(pageControl)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        layoutPageControl()
    }

    open func layoutPageControl() {
        pageControl.enforceContentSize()
//        pageControl.height.equal(to: 30)
//        pageControl.width.equal(to: self.view.width.times(0.5))
        pageControl.centerX.equal(to: self.view.centerX)
        pageControl.bottom.equal(to: self.bottom.inset(20))
    }


    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageControl.moveToFront()

    }

    open override func didTransition(to state: State) {
        super.didTransition(to: state)
        guard state == .empty else { return }
        pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
    }

    open func transitionToPage(at index: Int) {
        guard index >= 0, index < pagedViewControllers.count else {
            transition(to: .empty)
            return
        }

        guard index != currentPage else {
            return
        }
        guard isViewLoaded else {
            initialPageIndex = index
            return
        }
//        transition(to: .loading)
        let page = currentPage
        willPage(from: page, to: index)
        _performTransitionToPage(at: index)
        didPage(from: page, to: index)
    }

    open func willPage(from page: Int?, to nextPage: Int?) {
        pendingPage = nextPage
//        print("Will page from: \(page) to: \(nextPage)")
    }

    open func didCancelPaging(from page: Int?, to nextPage: Int?) {
//        print("Did cancel paging from: \(page) to: \(nextPage)")
        pendingPage = nil
    }
    

    private func _performTransitionToPage(at index: Int) {
        currentPagedViewController?.view.endEditing(true)
        let vc = pagedViewControllers[index]
        let direction: UIPageViewController.NavigationDirection = index > currentPage ?? 0 ? .forward : .reverse
        if let eagerLoadBuffer = eagerLoadBuffer {
            eagerLoadViewControllers(surrounding: index, by: eagerLoadBuffer)
        }
        pageViewController.setViewControllers([vc], direction: direction, animated: animatesPageTransitions, completion: nil)
        currentPage = index
    }

    open func didPage(from page: Int?, to nextPage: Int?) {
//        print("Did page from: \(page) to: \(nextPage)")
        currentPage = nextPage
        pendingPage = nil
    }


    open func eagerLoadViewControllers(surrounding index: Int, by buffer: Int) {
        let minIndex = 0
        let maxIndex = pagedViewControllers.lastIndex
        let startIndex = buffer == .max ? minIndex : max(index - buffer, minIndex)
        let lastIndex = buffer == .max ? maxIndex : min(index + buffer, maxIndex)
        guard startIndex < lastIndex else { return }
        for vc in pagedViewControllers[startIndex ... lastIndex] {
            vc.loadViewIfNeeded()
        }
    }

    open func transitionToPage(of viewController: UIViewController) {
        guard let index = pagedViewControllers.firstIndex(of: viewController) else {
            debugLog("Attempted to page to vc not in page index")
            return
        }
        transitionToPage(at: index)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if loadsPagesImmediately { reloadPages() }
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

        guard pagedViewControllers.count > previousIndex else {
            return nil
        }

        return pagedViewControllers[previousIndex]
    }

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pagedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = pagedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return pagedViewControllers[nextIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {

        guard let lastVC = self.pageViewController.viewControllers?.last else { return }

        guard finished else { return }

        guard completed else {
            didCancelPaging(from: currentPage, to: pendingPage)
            return
        }
        let newIndex = pagedViewControllers.index(of: lastVC)
        didPage(from: currentPage, to: newIndex)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let lastVC = pendingViewControllers.last else { return }
        willPage(from: currentPage, to: pagedViewControllers.index(of: lastVC))
    }

    open func reloadPageDatasource() {
        pagedViewControllers = createPagedViewControllers()
        currentPage = nil
    }

    open func reloadPages(initialPage: Int? = nil) {
        let index = initialPage ?? defaultReloadIndex()
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
        pageControl.numberOfPages = pagedViewControllers.count
        pageControl.currentPage = currentPage ?? 0
        //		transitionToPage(at: defaultReloadIndex())
    }

    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pagedViewControllers.count
    }

    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.pagedViewControllers.index(of: pageViewController) ?? 0
    }
}
