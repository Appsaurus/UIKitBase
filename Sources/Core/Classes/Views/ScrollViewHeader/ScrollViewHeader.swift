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
    override open var bounds: CGRect {
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
            self.setupBehaviors()
        }
    }

    public var expandedHeight: CGFloat {
        return self.expandedHeaderHeight + self.subheaderBackgroundView.frame.h
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
        return scrollView.contentOffset.y + scrollView.contentInset.top
    }

    public var headerHeightRange: CGFloat {
        return self.expandedHeight - self.collapsedHeaderHeight
    }

    public var percentCollapsed: CGFloat {
        let value = (expandedHeight - self.visibleHeaderHeight) / self.headerHeightRange
//        print("percentCollapsed unclamped \(value)")
        return value.clamped(0.0, 1.0)
    }

    public var percentExpanded: CGFloat {
        return (self.visibleHeaderHeight - self.collapsedHeaderHeight) / self.headerHeightRange
    }

    public var visibleHeaderHeight: CGFloat {
        return (self.expandedHeight - self.offset).clamped(self.collapsedHeaderHeight, self.expandedHeight)
    }

    func setupBehaviors() {
        self.behaviors.forEach { behavior in
            behavior.scrollViewHeader = self
        }
    }

    public required init(autoExpandingContentView: UIView,
                         width: CGFloat,
                         collapsedHeaderHeight: CGFloat = 0.0,
                         subheaderView: UIView? = nil,
                         subheaderCollapses: Bool = true,
                         behaviors: [ScrollViewHeaderBehavior] = []) {
        self._collapsedHeaderHeight = collapsedHeaderHeight
        autoExpandingContentView.layoutDynamicHeight(forWidth: width)
        self.expandedHeaderHeight = autoExpandingContentView.frame.h
        self.subheaderView = subheaderView
        self.subheaderCollapses = subheaderCollapses
        self.behaviors = behaviors
        super.init(frame: .zero)
        self.setupBehaviors()
    }

    public required init(expandedHeaderHeight: CGFloat,
                         collapsedHeaderHeight: CGFloat = 0.0,
                         subheaderView: UIView? = nil,
                         subheaderCollapses: Bool = true,
                         behaviors: [ScrollViewHeaderBehavior] = []) {
        self._collapsedHeaderHeight = collapsedHeaderHeight
        self.expandedHeaderHeight = expandedHeaderHeight
        self.subheaderView = subheaderView
        self.subheaderCollapses = subheaderCollapses
        self.behaviors = behaviors
        super.init(frame: .zero)
        self.setupBehaviors()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func createSubviews() {
        super.createSubviews()
        self.headerLayoutView.addSubview(self.headerBackgroundImageView)
//        headerLayoutView.insertSubview(headerLabel, aboveSubview: headerBackgroundImageView)
        addSubview(self.headerLayoutView)
        self.headerLayoutView.frame = self.bounds
        insertSubview(self.subheaderBackgroundView, aboveSubview: self.headerLayoutView)

        guard let subheader = subheaderView else { return }
        self.subheaderBackgroundView.addSubview(subheader)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()

        self.headerLayoutView.equal(to: edges.excluding(.bottom))
        self.backgroundViewConstraints.update(with: self.headerBackgroundImageView.centerInSuperview())
        self.backgroundViewConstraints.update(with: self.headerBackgroundImageView.width.greaterThanOrEqual(to: self.headerLayoutView))
        self.backgroundViewConstraints.update(with: self.headerBackgroundImageView.height.equal(to: self.headerLayoutView))
//        headerLabel.forceSuperviewToMatchContentSize(insetBy: LayoutPadding(20))
        guard let subheader = subheaderView else {
            self.headerLayoutView.bottom.equalToSuperview()
            return
        }
        self.subheaderBackgroundViewConstraints.update(with: self.subheaderBackgroundView.equal(to: edges.excluding(.top)))
        self.subheaderBackgroundViewConstraints.update(with: self.subheaderBackgroundView.top.equal(to: self.headerLayoutView.bottom))
        subheader.forceSuperviewToMatchContentSize()
        subheader.forceAutolayoutPass()
    }

    override open func initProperties() {
        super.initProperties()
        clipsToBounds = true
        self.headerBackgroundImageView.contentMode = .scaleAspectFill
        self.headerBackgroundImageView.isUserInteractionEnabled = true
    }

    var startTop: CGFloat?
    open func setupScrollViewRelatedConstraints() {
        if self.startTop == nil {
            self.startTop = scrollView.contentInset.top
        }
        let initialInsetTop = scrollView.contentInset.top

        self.viewConstraints.update(with: width.equal(to: scrollView.width))
        self.viewConstraints.update(with: top.equal(to: scrollView.top.inset(initialInsetTop)))
        self.viewConstraints.update(with: centerX.equal(to: scrollView.centerX))
        self.headerLayoutHeightConstraint = self.headerLayoutView.height.equal(to: self.expandedHeight) // .priority(.required)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.adjustViews(for: scrollView.contentOffset)
    }

//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        adjustViews(for: scrollView.contentOffset)
//    }

    // swiftlint:disable:next block_based_kvo
    override open func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        setNeedsLayout()
    }

    let parallaxFactor: CGFloat = 0.3

    open func adjustViews(for scrollViewOffset: CGPoint) {
        var topConstant = -scrollView.contentInset.top
        if self.visibleHeaderHeight <= self.collapsedHeaderHeight {
            topConstant = scrollViewOffset.y + self.collapsedHeaderHeight - self.expandedHeight
        }
        moveToFront()

//        if visibleHeaderHeight >= expandedHeight {
//            topConstant = scrollViewOffset.y + expandedHeight
//        }
        self.viewConstraints[.top]?.first?.constant = topConstant
//        print("topConstant: \(topConstant)")
        self.behaviors.forEach { behavior in
            behavior.adjustViews(for: self)
        }

        //        printViewConstraints()
//                debugPrintDescription()
    }

    func resetBackgroundViewSizeConstraints() {
        self.backgroundViewConstraints[.width]?.first?.constant = 0.0
        self.backgroundViewConstraints[.height]?.first?.constant = 0.0
    }

    func debugPrintDescription() {
//        print("startTop: \(startTop)")
        print("ScrollView header frame \(frame)")
        print("headerBackgroundImageView.frame: \(self.headerBackgroundImageView.frame)")
//        print("Screen Height \(UIScreen.screenHeight)")
        print("Parent vc height \(String(describing: scrollView.parentViewController?.view.frame.height))")
        print("Screen Height - content height \(UIScreen.screenHeight - scrollView.contentSize.height)")
//        print("Header state: \(headerState)")
        print("Offset: \(self.offset)")
        print("scrollView.frame: \(scrollView.frame)")
        print("scrollView.bounds: \(scrollView.bounds)")
        print("scrollView.contentsize: \(scrollView.contentSize)")
        print("scrollView.contentOffset.y: \(scrollView.contentOffset.y)")
        print("scrollView.contentInset.top: \(scrollView.contentInset.top)")
        print("scrollView.contentInset.bottom: \(scrollView.contentInset.bottom)")
        if #available(iOS 11.0, *) {
//            print("scrollView.adjustedContentInset: \(scrollView.adjustedContentInset)")
        } else {
            // Fallback on earlier versions
        }
        print("VisibleHeaderHeight \(self.visibleHeaderHeight)")
        print("collapsedHeaderHeight: \(self.collapsedHeaderHeight)")
        print("ExpandedHeight: \(self.expandedHeight)")
        print("ExpandedHeaderHeight: \(self.expandedHeaderHeight)")
        print("headerHeightRange: \(self.headerHeightRange)")
//        print("SubheaderHeight: \(subheaderBackgroundView.frame.h)")
        print("Percent collapsed: \(self.percentCollapsed)")
        print("Percent expanded: \(self.percentExpanded)")
//        printSubheaderBackgroundViewConstraints()
//        printBackgroundViewConstraints()
//        printViewConstraints()
    }

    func printSubheaderBackgroundViewConstraints() {
        print("Subheader backgroundview constriants")
        print("Subheader backgroundview height: \(String(describing: self.subheaderBackgroundViewConstraints[.height]?.first?.constant))")
        print("Subheader backgroundview subheader:  \(String(describing: self.subheaderBackgroundViewConstraints[.top]?.first?.constant))")
    }

    func printBackgroundViewConstraints() {
        print("Background constriants")
        print("centerX: \(String(describing: self.backgroundViewConstraints[.centerX]?.first?.constant))")
        print("centerY: \(String(describing: self.backgroundViewConstraints[.centerY]?.first?.constant))")
        print("width: \(String(describing: self.backgroundViewConstraints[.width]?.first?.constant))")
        print("height: \(String(describing: self.backgroundViewConstraints[.height]?.first?.constant))")
    }

    func printViewConstraints() {
        print("View constraints")
        print("centerX: \(String(describing: self.viewConstraints[.centerX]?.first?.constant))")
        print("top: \(String(describing: self.viewConstraints[.top]?.first?.constant))")
        print("width: \(String(describing: self.viewConstraints[.width]?.first?.constant))")
        print("headerLayoutHeightConstraint: \(String(describing: self.headerLayoutHeightConstraint?.constant))")
    }
}
