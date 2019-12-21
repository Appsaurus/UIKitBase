//
//  ScrollViewHeader.swift
//  Pods
//
//  Created by Brian Strobach on 4/25/17.
//
//

import Foundation
import Layman
import Swiftest

open class ScrollViewHeader: BaseView, ScrollViewObserver {
    open override var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                onBoundsChange?(bounds)
            }
        }
    }

    open var onBoundsChange: ((_ bounds: CGRect) -> Void)?

    public func scrollViewObserverDidObserveScroll(of scrollView: UIScrollView, to offset: CGPoint) {
        setNeedsLayout()
    }

    open var behaviors: [ScrollViewHeaderBehavior] = [] {
        didSet {
            setupBehaviors()
        }
    }

    public var expandedHeight: CGFloat {
        return expandedHeaderHeight + subheaderBackgroundView.frame.h
    }

    public var expandedHeaderHeight: CGFloat
    public var _collapsedHeaderHeight: CGFloat = 0.0
    public var collapsedHeaderHeight: CGFloat {
        guard let subheader = subheaderView, !subheaderCollapses else {
            return _collapsedHeaderHeight
        }
        return _collapsedHeaderHeight + subheader.frame.h
    }

    open var headerLayoutHeightConstraint: NSLayoutConstraint?
    open var viewConstraints: ConstraintAttributeMap = [:]
    open var headerState: ScrollViewHeaderState {
        switch visibleHeaderHeight {
        case -UIScreen.screenHeight ... collapsedHeaderHeight:
            return .collapsed
        case collapsedHeaderHeight ..< expandedHeight:
            return .transitioning
        case expandedHeight:
            return .expanded
        case expandedHeight ... UIScreen.screenHeight:
            return .stretched
        default:
            assertionFailure("Unhandled range")
            return .collapsed
        }
    }

    open var subheaderView: UIView?
    open lazy var subheaderBackgroundView: UIView = UIView()
    open var subheaderBackgroundViewConstraints: ConstraintAttributeMap = [:]
    open var subheaderCollapses: Bool = true

    open var headerLayoutView: UIView = UIView()
    open var headerBackgroundImageView: BaseImageView = BaseImageView()
    open var headerLabel: UILabel = UILabel().then { label in
        label.wrapWords()
    }

    var backgroundViewConstraints: ConstraintAttributeMap = [:]

    public var offset: CGFloat {
        return  scrollView.contentOffset.y + scrollView.contentInset.top
    }

    public var headerHeightRange: CGFloat {
        return expandedHeight - collapsedHeaderHeight
    }

    public var percentCollapsed: CGFloat {
        let value = (expandedHeight - visibleHeaderHeight) / headerHeightRange
        print("percentCollapsed unclamped \(value)")
        return value.clamped(0.0, 1.0)
    }

    public var percentExpanded: CGFloat {
        return visibleHeaderHeight / expandedHeight
    }

    public var visibleHeaderHeight: CGFloat {
        let height = expandedHeight + frame.y
        print("height unclamped \(height)")
//        return height
        return height.clamped(collapsedHeaderHeight, expandedHeight)
    }

    func setupBehaviors() {
        behaviors.forEach { behavior in
            behavior.scrollViewHeader = self
        }
    }

    public required init(autoExpandingContentView: UIView,
                         width: CGFloat,
                         collapsedHeaderHeight: CGFloat = 0.0,
                         subheaderView: UIView? = nil,
                         subheaderCollapses: Bool = true,
                         behaviors: [ScrollViewHeaderBehavior] = []) {
        _collapsedHeaderHeight = collapsedHeaderHeight
        autoExpandingContentView.layoutDynamicHeight(forWidth: width)
        expandedHeaderHeight = autoExpandingContentView.frame.h
        self.subheaderView = subheaderView
        self.subheaderCollapses = subheaderCollapses
        self.behaviors = behaviors
        super.init(frame: .zero)
        setupBehaviors()
    }

    public required init(expandedHeaderHeight: CGFloat,
                         collapsedHeaderHeight: CGFloat = 0.0,
                         subheaderView: UIView? = nil,
                         subheaderCollapses: Bool = true,
                         behaviors: [ScrollViewHeaderBehavior] = []) {
        _collapsedHeaderHeight = collapsedHeaderHeight
        self.expandedHeaderHeight = expandedHeaderHeight
        self.subheaderView = subheaderView
        self.subheaderCollapses = subheaderCollapses
        self.behaviors = behaviors
        super.init(frame: .zero)
        setupBehaviors()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func createSubviews() {
        super.createSubviews()
        headerLayoutView.addSubview(headerBackgroundImageView)
//        headerLayoutView.insertSubview(headerLabel, aboveSubview: headerBackgroundImageView)
        addSubview(headerLayoutView)
        headerLayoutView.frame = bounds
        insertSubview(subheaderBackgroundView, aboveSubview: headerLayoutView)

        guard let subheader = subheaderView else { return }
        subheaderBackgroundView.addSubview(subheader)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()

        headerLayoutView.equal(to: edges.excluding(.bottom))
        backgroundViewConstraints.update(with: headerBackgroundImageView.centerInSuperview())
        backgroundViewConstraints.update(with: headerBackgroundImageView.width.greaterThanOrEqual(to: headerLayoutView))
        backgroundViewConstraints.update(with: headerBackgroundImageView.height.equal(to: headerLayoutView))
//        headerLabel.forceSuperviewToMatchContentSize(insetBy: LayoutPadding(20))
        subheaderBackgroundViewConstraints.update(with: subheaderBackgroundView.equal(to: edges.excluding(.top)))
        subheaderBackgroundViewConstraints.update(with: subheaderBackgroundView.top.equal(to: headerLayoutView.bottom))
        subheaderView?.forceSuperviewToMatchContentSize()
        subheaderView?.forceAutolayoutPass()
    }

    open override func initProperties() {
        super.initProperties()
        clipsToBounds = true
        headerBackgroundImageView.contentMode = .scaleAspectFill
        headerBackgroundImageView.isUserInteractionEnabled = true
    }

    var startTop: CGFloat?
    open func setupScrollViewRelatedConstraints() {
        if startTop == nil {
            startTop = scrollView.contentInset.top
        }
        let initialInsetTop = scrollView.contentInset.top

        viewConstraints.update(with: width.equal(to: scrollView.width))
        viewConstraints.update(with: top.equal(to: scrollView.top.inset(initialInsetTop)))
        viewConstraints.update(with: centerX.equal(to: scrollView.centerX))
        headerLayoutHeightConstraint = headerLayoutView.height.equal(to: expandedHeight).priority(.required)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        adjustViews(for: scrollView.contentOffset)
    }

//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        adjustViews(for: scrollView.contentOffset)
//    }

    // swiftlint:disable:next block_based_kvo
    open override func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        setNeedsLayout()
    }

    let parallaxFactor: CGFloat = 0.3

    open func adjustViews(for scrollViewOffset: CGPoint) {
        var topConstant = -scrollView.contentInset.top
        if visibleHeaderHeight <= collapsedHeaderHeight {
            topConstant = scrollViewOffset.y + collapsedHeaderHeight - expandedHeight
        }

//        if visibleHeaderHeight >= expandedHeight {
//            topConstant = scrollViewOffset.y + expandedHeight
//        }
        viewConstraints[.top]?.first?.constant = topConstant
        print("topConstant: \(topConstant)")
//        behaviors.forEach { behavior in
//            behavior.adjustViews(for: self)
//        }

        //        printViewConstraints()
                debugPrintDescription()
    }

    func resetBackgroundViewSizeConstraints() {
        backgroundViewConstraints[.width]?.first?.constant = 0.0
        backgroundViewConstraints[.height]?.first?.constant = 0.0
    }

    func debugPrintDescription() {
        print("startTop: \(startTop)")
        print("ScrollView header frame \(frame)")
        print("headerBackgroundImageView.frame: \(headerBackgroundImageView.frame)")
        print("Screen Height \(UIScreen.screenHeight)")
        print("Parent vc height \(scrollView.parentViewController?.view.frame.height)")
        print("Screen Height - content height \(UIScreen.screenHeight - scrollView.contentSize.height)")
        print("Header state: \(headerState)")
        print("Offset: \(offset)")
        print("scrollView.frame: \(scrollView.frame)")
        print("scrollView.bounds: \(scrollView.bounds)")
        print("scrollView.contentsize: \(scrollView.contentSize)")
        print("scrollView.contentOffset.y: \(scrollView.contentOffset.y)")
        print("scrollView.contentInset.top: \(scrollView.contentInset.top)")
        print("scrollView.contentInset.bottom: \(scrollView.contentInset.bottom)")
        if #available(iOS 11.0, *) {
            print("scrollView.adjustedContentInset: \(scrollView.adjustedContentInset)")
        } else {
            // Fallback on earlier versions
        }
        print("VisibleHeaderHeight \(visibleHeaderHeight)")
        print("collapsedHeaderHeight: \(collapsedHeaderHeight)")
        print("ExpandedHeight: \(expandedHeight)")
        print("ExpandedHeaderHeight: \(expandedHeaderHeight)")
        print("headerHeightRange: \(headerHeightRange)")
        print("SubheaderHeight: \(subheaderBackgroundView.frame.h)")
        print("Percent collapsed: \(percentCollapsed)")
        print("Percent expanded: \(percentExpanded)")
        printSubheaderBackgroundViewConstraints()
        printBackgroundViewConstraints()
        printViewConstraints()
    }

    func printSubheaderBackgroundViewConstraints() {
        print("Subheader backgroundview constriants")
        print("Subheader backgroundview height: \(String(describing: subheaderBackgroundViewConstraints[.height]?.first?.constant))")
        print("Subheader backgroundview subheader:  \(String(describing: subheaderBackgroundViewConstraints[.top]?.first?.constant))")
    }

    func printBackgroundViewConstraints() {
        print("Background constriants")
        print("centerX: \(String(describing: backgroundViewConstraints[.centerX]?.first?.constant))")
        print("centerY: \(String(describing: backgroundViewConstraints[.centerY]?.first?.constant))")
        print("width: \(String(describing: backgroundViewConstraints[.width]?.first?.constant))")
        print("height: \(String(describing: backgroundViewConstraints[.height]?.first?.constant))")
    }

    func printViewConstraints() {
        print("View constraints")
        print("centerX: \(String(describing: viewConstraints[.centerX]?.first?.constant))")
        print("top: \(String(describing: viewConstraints[.top]?.first?.constant))")
        print("width: \(String(describing: viewConstraints[.width]?.first?.constant))")
        print("headerLayoutHeightConstraint: \(String(describing: headerLayoutHeightConstraint?.constant))")
    }
}
