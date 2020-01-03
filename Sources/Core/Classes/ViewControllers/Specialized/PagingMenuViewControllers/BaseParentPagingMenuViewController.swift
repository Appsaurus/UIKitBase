//
//  BaseScrollViewParentPagingMenuViewController.swift
//  Pods
//
//  Created by Brian Strobach on 7/9/17.
//
//

import Swiftest
import UIKitExtensions
import UIKitTheme

open class BaseParentPagingMenuViewController: BaseParentPagingViewController, PagingMenuViewDelegate {
    open override func initProperties() {
        super.initProperties()
        pagingMenuView.initialSelectedMenuIndexPath = initialPageIndex.indexPath
    }

    open override func createHeaderView() -> UIView? {
        return pagingMenuView
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pagingMenuView.invalidateLayout()
    }

    // MARK: PagingMenuVIew

    open lazy var pagingMenuView: PagingMenuView = {
        self.createPagingMenuView()
    }()

    open func createPagingMenuView() -> PagingMenuView {
        return PagingMenuView(delegate: self, options: pagingMenuViewOptions)
    }

    open var pagingMenuViewOptions: PagingMenuViewOptions {
        let menuHeight: CGFloat = 50.0
        return PagingMenuViewOptions(layout: .horizontal(height: menuHeight), itemSizingBehavior: .spanWidthCollectively(height: menuHeight), scrollBehavior: .tabBar)
    }

    open override func didPage(from page: Int?, to nextPage: Int?) {
        super.didPage(from: page, to: nextPage)
        guard let nextPage = nextPage else { return }
        pagingMenuView.selectItem(at: nextPage)
    }

    open override func didCancelPaging(from page: Int?, to nextPage: Int?) {
        super.didCancelPaging(from: page, to: nextPage)
        guard let page = page else { return }
        pagingMenuView.selectItem(at: page)
    }

    // MARK: PagingMenuViewDelegate

    open func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
        return defaultMenuItemCellClasses()
    }

    open func pagingMenuNumberOfItems(for menuView: PagingMenuView) -> Int {
        return pagedViewControllers.count
    }

    open func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return PagingMenuItemCell<UIView>()
    }

    open func pagingMenuView(menuView: PagingMenuView, didSelectMenuItemCell: PagingMenuItemCell<UIView>, at index: Int) {
        guard currentPage != index, pendingPage == nil else { return }
        transitionToPage(at: index)
    }

    open func pagingMenuView(menuView: PagingMenuView, didReselectCurrentMenuItemCell: PagingMenuItemCell<UIView>, at index: Int) {}

    open func pagingMenuView(menuView: PagingMenuView, canSelectItemAtIndex index: Int) -> Bool {
        return true
    }

    open override func pagesDidReload() {
        pagingMenuView.reloadItems(selectedIndex: initialPageIndex.indexPath, animated: false) // Keep menu synced with datasource
        super.pagesDidReload()
    }

    // For manually sizing cells when PagingMenuItemSizingBehavior is set to delegateSizing

    open func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return .zero
    }
}

/// /
/// /  BaseScrollViewParentPagingMenuViewController.swift
/// /  Pods
/// /
/// /  Created by Brian Strobach on 7/9/17.
/// /
/// /
//
// import Foundation
// import UIKit
// import Swiftest
//
// open class BaseParentPagingMenuViewController: BaseParentPagingViewController, PagingMenuViewDelegate{
//
//	override open func createHeaderView() -> UIView? {
//		return pagingMenuView
//	}
//
/// /	open override func viewDidLoad() {
/// /		super.viewDidLoad()
/// /		pagingMenuView.initialSelectedMenuIndexPath = initialPageIndex.indexPath
/// /		pagingMenuView.transitionToInitialSelectionState()
/// /	}
//
//	open override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//
//		enqueue { (completion) in
//			self.transitionToPage(at: 1)
//			completion()
//		}
//
//	}
//

// MARK: PagingMenuVIew

//	open lazy var pagingMenuView: PagingMenuView = {
//		return self.createPagingMenuView()
//	}()
//
//
//	open func createPagingMenuView() -> PagingMenuView{
//		return PagingMenuView(delegate: self, options: pagingMenuViewOptions)
//	}
//
//	open var pagingMenuViewOptions: PagingMenuViewOptions{
//		let menuHeight: CGFloat = 50.0
//		return PagingMenuViewOptions(layout: .horizontal(height: menuHeight), itemSizingBehavior: .spanWidthCollectively(height: menuHeight), scrollBehavior: .tabBar)
//	}
//
//	open override func transitionToPage(at index: Int) {
//		guard isViewLoaded, pagingMenuView.hasLoadedInitialState else{ //Has not loaded yet
//			initialPageIndex = index
//			return
//		}
//		super.transitionToPage(at: index)
//	}
//

// MARK: PagingMenuViewDelegate

//	open func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type]{
//		return defaultMenuItemCellClasses()
//	}
//
//	open func pagingMenuNumberOfItems(for menuView: PagingMenuView) -> Int {
//		return pagedViewControllers.count
//	}
//
//	open func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
//		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//		return PagingMenuItemCell<UIView>()
//	}
//
//	open func pagingMenuView(menuView: PagingMenuView, didSelectMenuItemCell: PagingMenuItemCell<UIView>, at index: Int) {
/// /		guard index != currentPage else {
/// /			return
/// /		}
//		DispatchQueue.main.async {
//			super.transitionToPage(at: index)
//		}
//
//	}
//
//	open func pagingMenuView(menuView: PagingMenuView, didReselectCurrentMenuItemCell: PagingMenuItemCell<UIView>, at index: Int) {
//
//	}
//
//	open func pagingMenuView(menuView: PagingMenuView, canSelectItemAtIndex index: Int) -> Bool {
//		return true
//	}
//
//
//	//For manually sizing cells when PagingMenuItemSizingBehavior is set to delegateSizing
//
//	open func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize{
//		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//		return .zero
//	}
//
//	open override func reloadPages(initialPage: Int?) {
//		let index = initialPage ?? defaultReloadIndex()
//		self.pagingMenuView.reloadItems(selectedIndex: index, animated: false) {
//			DispatchQueue.main.async {
//				super.reloadPages(initialPage: index)
//				self.pagingMenuView.selectItemProgramtically(at: index, animated: false)
//			}
//		}
//
//	}
// }
//
//
