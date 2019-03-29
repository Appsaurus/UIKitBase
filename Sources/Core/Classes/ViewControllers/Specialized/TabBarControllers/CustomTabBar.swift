//
//  CustomTabBar.swift
//  Pods
//
//  Created by Brian Strobach on 4/6/17.
//
//

import Actions
import Swiftest
import UIKit
import UIKitExtensions
public protocol CustomTabBarDataSource {
    func numberOfTabBarItems() -> Int
    func tabBarItemViewForItem(at index: Int) -> CustomTabBarItemView
}

public protocol CustomTabBarDelegate: AnyObject {
    func customTabBar(_ tabBar: CustomTabBar, didSelectItemAtIndex index: Int)
    func customTabBarDidReselectItemAtCurrentIndex(_ tabBar: CustomTabBar)
    func customTabBar(_ tabBar: CustomTabBar, shouldSelectItemAtIndex index: Int) -> Bool
}

extension CustomTabBarDelegate {
    func customTabBar(_ tabBar: CustomTabBar, shouldSelectItemAtIndex index: Int) -> Bool {
        return true
    }
}

public protocol CustomTabBarItemProtocol {}

open class CustomTabBar: PassThroughView, CollectionMenuSelectionAnimator {
    open var datasource: CustomTabBarDataSource
    open weak var delegate: CustomTabBarDelegate?
    public var hasLoadedInitialState: Bool = false
    open var items: [CustomTabBarItemView] = []

    public var selectedMenuIndexPath: IndexPath?
    public var initialSelectedMenuIndexPath: IndexPath? = 0
    open var stackView = UIStackView()

    open var selectionIndicatorView: UIView?
    open var selectionIndicatorAnimation: CollectionMenuSelectionIndicatorAnimation = .stretchSlidingFrame

    public required init(datasource: CustomTabBarDataSource, delegate: CustomTabBarDelegate, initialIndex: Int = 0) {
        self.datasource = datasource
        self.delegate = delegate
        initialSelectedMenuIndexPath = initialIndex.indexPath
        super.init(frame: .zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func createSubviews() {
        super.createSubviews()
        setupTabBar()
        if let selectionIndicatorView = selectionIndicatorView {
            addSubview(selectionIndicatorView)
        }
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        layoutTabBar()
    }

    open func setupTabBar() {
        addSubview(stackView)
    }

    open func layoutTabBar() {
        stackView.pinToSuperview()
    }

    open func selectItem(at indexPath: IndexPath?, animated: Bool = true) {
        selectCollectionMenuItem(at: indexPath, animated: animated)
    }

    open func reloadItems(selectedIndex: IndexPath? = nil, animated: Bool, completion: VoidClosure? = nil) {
        var items: [CustomTabBarItemView] = []

        if datasource.numberOfTabBarItems() > 0 {
            for index in 0 ... datasource.numberOfTabBarItems() - 1 {
                items.append(datasource.tabBarItemViewForItem(at: index))
            }
        }
        self.items = items

        stackView.swapArrangedSubviews(for: items)
        guard items.count > 1 else { return }
        items.forEach { view in
            view.onTap = { [weak self] in
                guard let self = self else { return }
                self.barItemTapped(sender: view)
            }
        }
        guard let selectedIndex = selectedIndex ?? initialSelectedMenuIndexPath else { return }
        selectCollectionMenuItem(at: selectedIndex, animated: false)
        completion?()
    }

    open func barItemTapped(sender: CustomTabBarItemView) {
        let index = items.index(of: sender)!
        guard delegate?.customTabBar(self, shouldSelectItemAtIndex: index) == true else { return }
        userDidSelectCollectionMenuItem(at: IndexPath(item: index, section: 0))
    }

    // MARK: CollectionViewAnimator

    open func didSelectCollectionMenuItem(at indexPath: IndexPath?) {
        guard let index = indexPath?.intIndex else { return }
        delegate?.customTabBar(self, didSelectItemAtIndex: index)
    }

    open func renderCollectionMenuItemSelection(transition: IndexPathTransition) {
        if let fromIndex = transition.route.from?.intIndex {
            items[safe: fromIndex]?.state = .normal
        }
        if let toIndex = transition.route.to?.intIndex {
            items[safe: toIndex]?.state = .selected
        }
    }

    public func userDidReselectCollectionMenuItem(at indexPath: IndexPath) {}

    public func viewForSelectedCollectioMenuItem() -> UIView? {
        guard let index = selectedMenuIndexPath else { return nil }
        return items[safe: index.intIndex]
    }
}

extension IndexPath {
    public func equals(_ otherIndex: IndexPath?) -> Bool {
        guard let otherIndex = otherIndex else { return false }
        return self == otherIndex
    }

    public var intIndex: Int {
        return item
    }
}

public struct IndexPathRoute {
    public var from: IndexPath?
    public var to: IndexPath?

    public init(from: IndexPath? = nil, to: IndexPath? = nil) {
        self.from = from
        self.to = to
    }
}

public struct IndexPathTransition {
    public var route: IndexPathRoute
    public var animated: Bool

    public init(from: IndexPath? = nil, to: IndexPath? = nil, animated: Bool = true) {
        route = IndexPathRoute(from: from, to: to)
        self.animated = animated
    }
}

public protocol CollectionMenuSelectionAnimator: AnyObject {
    var hasLoadedInitialState: Bool { get set }
    var selectionIndicatorView: UIView? { get set }
    var selectedMenuIndexPath: IndexPath? { get set }
    var initialSelectedMenuIndexPath: IndexPath? { get set }
    var selectionIndicatorAnimation: CollectionMenuSelectionIndicatorAnimation { get set }

    func userDidSelectCollectionMenuItem(at indexPath: IndexPath?) // User starting point to trigger transition
    func userDidReselectCollectionMenuItem(at indexPath: IndexPath)

    func selectCollectionMenuItem(at index: IndexPath?, animated: Bool) // Programmatic starting point to trigger transition without knowledge of curent selection
    func didSelectCollectionMenuItem(at index: IndexPath?)

    func transitionSelectionState(transition: IndexPathTransition)

    func transitionToInitialSelectionState()
    func renderCollectionMenuSelection(transition: IndexPathTransition)
    func renderCollectionMenuItemSelection(transition: IndexPathTransition)
    func renderCollectionMenuItemSelectionIndicator(transition: IndexPathTransition)

    func viewForSelectedCollectioMenuItem() -> UIView?
    func reloadItems(selectedIndex: IndexPath?, animated: Bool, completion: VoidClosure?)
}

extension CollectionMenuSelectionAnimator {
    public func userDidSelectCollectionMenuItem(at indexPath: IndexPath?) {
        if let selectedMenuIndexPath = selectedMenuIndexPath, selectedMenuIndexPath.equals(indexPath) {
            userDidReselectCollectionMenuItem(at: selectedMenuIndexPath)
            return
        }
        selectCollectionMenuItem(at: indexPath, animated: true)
    }

    public func selectCollectionMenuItem(at indexPath: IndexPath?, animated: Bool = true) {
        //        guard hasLoadedInitialState else{
        //            initialSelectedMenuIndexPath = indexPath
        //            return
        //        }
        let change = IndexPathTransition(from: selectedMenuIndexPath, to: indexPath, animated: animated)
        transitionSelectionState(transition: change)
        didSelectCollectionMenuItem(at: indexPath)
    }

    public func transitionToInitialSelectionState() {
        hasLoadedInitialState = true
        transitionSelectionState(transition: IndexPathTransition(to: initialSelectedMenuIndexPath, animated: false))
    }

    public func transitionSelectionState(transition: IndexPathTransition) {
        DispatchQueue.mainSyncSafe {
            selectedMenuIndexPath = transition.route.to
        }
        renderCollectionMenuSelection(transition: transition)
    }

    public func renderCollectionMenuSelection(transition: IndexPathTransition) {
        renderCollectionMenuItemSelection(transition: transition)
        renderCollectionMenuItemSelectionIndicator(transition: transition)
    }

    public func rerenderCollectionMenuSelection() {
        let transition = IndexPathTransition(to: selectedMenuIndexPath, animated: false)
        renderCollectionMenuItemSelection(transition: transition)
        renderCollectionMenuItemSelectionIndicator(transition: transition)
    }

    public func renderCollectionMenuItemSelectionIndicator(transition: IndexPathTransition) {
        guard let selectionIndicatorView = self.selectionIndicatorView else { return }

        DispatchQueue.main.async {
            guard let selectedMenuView = self.viewForSelectedCollectioMenuItem() else {
                selectionIndicatorView.frame = .zero
                selectionIndicatorView.hide()
                return
            }
            selectionIndicatorView.moveToFront()

            guard transition.route.from != nil else {
                selectionIndicatorView.frame = self.selectionIndicatorAnimation.finalFrameForSelectionIndicator(view: selectionIndicatorView, whenAnimatedTo: selectedMenuView)
                selectionIndicatorView.show()
                return
            }
            guard transition.animated else {
                selectionIndicatorView.frame = self.selectionIndicatorAnimation.finalFrameForSelectionIndicator(view: selectionIndicatorView, whenAnimatedTo: selectedMenuView)
                selectionIndicatorView.isVisible = true
                return
            }
            self.selectionIndicatorAnimation.animateLayoutOfSelectionIndicator(view: selectionIndicatorView, to: selectedMenuView, completion: {
                selectionIndicatorView.show()
            })
        }
    }

    // MARK: Convenience

    public func selectItem(at index: Int, animated: Bool = true) {
        guard selectedMenuIndexPath?.intIndex != index else { return }
        selectCollectionMenuItem(at: index.indexPath, animated: animated)
    }
}

public class CollectionMenuSelectionIndicatorAnimation {
    open func animateLayoutOfSelectionIndicator(view: UIView, to selectedView: UIView, completion: VoidClosure? = nil) {
        let configuration: SpringAnimationConfiguration = SpringAnimationConfiguration(duration: 0.4, springDamping: 0.7)
        DispatchQueue.main.async {
            view.springAnimate(configuration: configuration, animations: {
                view.frame = self.finalFrameForSelectionIndicator(view: view, whenAnimatedTo: selectedView)
            }, completion: completion)
        }
    }

    open func finalFrameForSelectionIndicator(view: UIView, whenAnimatedTo selectedView: UIView) -> CGRect {
        var frame = CGRect()
        frame.w = selectedView.frame.w
        frame.h = 2.0
        frame.x = selectedView.frame.minX
        frame.y = selectedView.frame.maxY - view.frame.h
        return frame
    }

    public static var slidingUnderline: CollectionMenuSelectionIndicatorAnimation {
        return CollectionMenuSelectionIndicatorAnimation()
    }

    public static var stretchSlidingFrame: SlidingFrameMenuSelectionIndicatorAnimation {
        return SlidingFrameMenuSelectionIndicatorAnimation()
    }
}

public class SlidingFrameMenuSelectionIndicatorAnimation: CollectionMenuSelectionIndicatorAnimation {
    open override func animateLayoutOfSelectionIndicator(view: UIView, to selectedView: UIView, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            let destinationFrame = self.finalFrameForSelectionIndicator(view: view, whenAnimatedTo: selectedView)
            let time = 0.3
            let configuration = AnimationConfiguration(duration: time, options: .curveEaseInOut)
            let delayedConfiguration = AnimationConfiguration(duration: time / 2.0, delay: time / 2.0, options: .curveEaseInOut)
            view.animate(configuration: configuration, animations: {
                view.frame = view.frame.union(destinationFrame)
            })
            view.animate(configuration: delayedConfiguration, animations: {
                view.frame = destinationFrame
            })
        }
    }

    open override func finalFrameForSelectionIndicator(view: UIView, whenAnimatedTo selectedView: UIView) -> CGRect {
        return selectedView.frame(in: view)
    }
}
