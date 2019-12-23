
//
//  CustomTabBarController.swift
//  Pods
//
//  Created by Brian Strobach on 4/6/17.
//
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

public enum CustomTabBarLayout {
    case bottom(height: CGFloat)
    case top(height: CGFloat)
    case left(width: CGFloat)
    case right(width: CGFloat)
}

open class CustomTabBarController: BaseTabBarController, CustomTabBarDataSource, CustomTabBarDelegate {
    open lazy var customTabBar: CustomTabBar = CustomTabBar(datasource: self, delegate: self, initialIndex: self.initialSelectedIndex ?? 0)
    open var tabBarLayout: CustomTabBarLayout = .bottom(height: 50.0)
    open var appliesTabBarItemTitlesToViewControllerTitles: Bool = true
    open var eagerLoadsViewControllers: Bool = true
    open var initialViewControllers: [UIViewController] = []

    open var tabBarStackViewConfiguration: StackViewConfiguration {
        switch tabBarLayout {
        case .bottom, .top:
            return .fillEquallyHorizontal(spacing: 0.0)
        case .left, .right:
            return .equalSpacingVertical(alignment: .fill, spacing: 0.0)
        }
    }

    open var tabBarLayoutView: UIView = UIView()
    open lazy var contentPadding: CGFloat = 25.0

    open override var selectedIndex: Int {
        didSet {
            customTabBar.selectItem(at: selectedIndex)
        }
    }

    open override func style() {
        super.style()
        tabBarLayoutView.apply(viewStyle: .raised(backgroundColor: App.style.tabBar.defaults.backgroundColor))
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        customTabBar.stackView.apply(stackViewConfiguration: tabBarStackViewConfiguration)
    }

    open override func viewDidLoad() {
        delegate = self
        tabBar.removeFromSuperview()
        customTabBar.initialSelectedMenuIndexPath = initialSelectedIndex?.indexPath
        initialViewControllers.enumerated().forEach { index, vc in
            vc.tabBarItem.tag = index
            if appliesTabBarItemTitlesToViewControllerTitles { vc.title = vc.tabBarItem.title }
        }

        setViewControllers(initialViewControllers, animated: false)
        super.viewDidLoad()
        customTabBar.forceAutolayoutPass()
        customTabBar.transitionToInitialSelectionState()
    }

    open override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        customTabBar.reloadItems(animated: animated)
        if eagerLoadsViewControllers {
            viewControllers?.loadViewIfNeeded()
        }
    }

    open override func createSubviews() {
        super.createSubviews()
        view.addSubview(tabBarLayoutView)
        tabBarLayoutView.addSubview(customTabBar)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        createTabBarAutolayoutConstraints()
        tabBarLayoutView.layoutMargins = .zero
    }

    open func createTabBarAutolayoutConstraints() {
        guard let contentView = contentView else { return }
        customTabBar.edges.equalToSuperviewMargin()
        switch tabBarLayout {
        case let .bottom(height):
            [contentView, tabBarLayoutView].stack(.topToBottom, in: self)
            customTabBar.height.equal(to: height)
        case let .top(height):
            [tabBarLayoutView, contentView].stack(.topToBottom, in: self)
            customTabBar.height.equal(to: height)
        case let .left(width):
            [tabBarLayoutView, contentView].stack(.leadingToTrailing, in: self)
            customTabBar.width.equal(to: width)
        case let .right(width):
            [contentView, tabBarLayoutView].stack(.leadingToTrailing, in: self)
            customTabBar.width.equal(to: width)
        }
    }

    // MARK: - CustomTabBarDataSource

    open func customTabBar(_ tabBar: CustomTabBar, shouldSelectItemAtIndex index: Int) -> Bool {
        guard let vc = self.viewControllers?[index] else { return false }
        return tabBarController(self, shouldSelect: vc)
    }

    open func numberOfTabBarItems() -> Int {
        return viewControllers?.count ?? 0
    }

    open func tabBarItemViewForItem(at index: Int) -> CustomTabBarItemView {
        return CustomTabBarItemView(tabBarItem: viewControllers![index].tabBarItem)
    }

    // MARK: - CustomTabBarDelegate

    open func customTabBarDidReselectItemAtCurrentIndex(_ tabBar: CustomTabBar) {
        guard let index = tabBar.selectedMenuIndexPath?.intIndex else { return }
        guard let childVC = self.viewControllers?[index] as? TabBarChild else {
            return
        }

        childVC.tabItemWasTappedWhileActive()
    }

    open func customTabBar(_ tabBar: CustomTabBar, didSelectItemAtIndex index: Int) {
        guard let selectedVC = self.viewControllers?[index] else { return }
        guard tabBarController(self, shouldSelect: selectedVC) else { return }
        guard selectedIndex != index else { return }
        selectedIndex = index
        tabBarController(self, didSelect: selectedVC)
    }

    open override func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        super.tabBarController(tabBarController, didSelect: viewController)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.isHidden = true
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(customTabBar)
        tabBar.isHidden = true
    }

    // MARK: Convenience

    open func transition(to childViewController: UIViewController) {
        guard let index = childViewController.tabBarItem?.tag ?? viewControllers?.firstIndex(of: childViewController),
            index != selectedIndex else { return }
        selectedIndex = index
    }
}
