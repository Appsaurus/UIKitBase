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

    override open var selectedIndex: Int {
        didSet {
            customTabBar.selectItem(at: selectedIndex)
        }
    }

    override open func style() {
        super.style()
        self.tabBarLayoutView.apply(viewStyle: .raised(backgroundColor: App.style.tabBar.defaults.backgroundColor))
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        self.customTabBar.stackView.apply(stackViewConfiguration: self.tabBarStackViewConfiguration)
    }

    override open func viewDidLoad() {
        delegate = self
        tabBar.removeFromSuperview()
        self.customTabBar.initialSelectedMenuIndexPath = initialSelectedIndex?.indexPath
        self.initialViewControllers.enumerated().forEach { index, vc in
            vc.tabBarItem.tag = index
            if appliesTabBarItemTitlesToViewControllerTitles { vc.title = vc.tabBarItem.title }
        }

        self.setViewControllers(self.initialViewControllers, animated: false)
        super.viewDidLoad()
        self.customTabBar.forceAutolayoutPass()
        self.customTabBar.transitionToInitialSelectionState()
    }

    override open func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        self.customTabBar.reloadItems(animated: animated)
        if self.eagerLoadsViewControllers {
            viewControllers?.loadViewIfNeeded()
        }
    }

    override open func createSubviews() {
        super.createSubviews()
        view.addSubview(self.tabBarLayoutView)
        self.tabBarLayoutView.addSubview(self.customTabBar)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.createTabBarAutolayoutConstraints()
        self.tabBarLayoutView.layoutMargins = .zero
    }

    open func createTabBarAutolayoutConstraints() {
        guard let contentView = contentView else { return }
        self.customTabBar.edges.equalToSuperviewMargin()
        switch self.tabBarLayout {
        case let .bottom(height):
            [contentView, self.tabBarLayoutView].stack(.topToBottom, in: self)
            self.customTabBar.height.equal(to: height)
        case let .top(height):
            [self.tabBarLayoutView, contentView].stack(.topToBottom, in: self)
            self.customTabBar.height.equal(to: height)
        case let .left(width):
            [self.tabBarLayoutView, contentView].stack(.leadingToTrailing, in: self)
            self.customTabBar.width.equal(to: width)
        case let .right(width):
            [contentView, self.tabBarLayoutView].stack(.leadingToTrailing, in: self)
            self.customTabBar.width.equal(to: width)
        }
    }

    // MARK: - CustomTabBarDataSource

    open func customTabBar(_ tabBar: CustomTabBar, shouldSelectItemAtIndex index: Int) -> Bool {
        guard let vc = viewControllers?[index] else { return false }
        return self.tabBarController(self, shouldSelect: vc)
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
        guard let childVC = viewControllers?[index] as? TabBarChild else {
            return
        }

        childVC.tabItemWasTappedWhileActive()
    }

    open func customTabBar(_ tabBar: CustomTabBar, didSelectItemAtIndex index: Int) {
        guard let selectedVC = viewControllers?[index] else { return }
        guard self.tabBarController(self, shouldSelect: selectedVC) else { return }
        guard self.selectedIndex != index else { return }
        self.selectedIndex = index
        self.tabBarController(self, didSelect: selectedVC)
    }

    override open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        super.tabBarController(tabBarController, didSelect: viewController)
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.isHidden = true
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(self.customTabBar)
        tabBar.isHidden = true
    }

    // MARK: Convenience

    open func transition(to childViewController: UIViewController) {
        guard let index = childViewController.tabBarItem?.tag ?? viewControllers?.firstIndex(of: childViewController),
            index != selectedIndex else { return }
        self.selectedIndex = index
    }
}
