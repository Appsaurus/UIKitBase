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
        didSet{
            if oldValue != bounds{
                onBoundsChange?(bounds)
            }
        }
    }
    open var onBoundsChange: ((_ bounds: CGRect) -> Void)?

    public func scrollViewObserverDidObserveScroll(of scrollView: UIScrollView, to offset: CGPoint) {
        setNeedsLayout()
    }

    
    open var behaviors: [ScrollViewHeaderBehavior] = []{
        didSet{
            setupBehaviors()
        }
    }
    
    public var expandedHeight: CGFloat{
        return expandedHeaderHeight + subheaderBackgroundView.frame.h
    }
    
    public var expandedHeaderHeight: CGFloat
    public var collapsedHeaderHeight: CGFloat = 0.0
    
    open var headerLayoutHeightConstraint: NSLayoutConstraint?
    open var viewConstraints: ConstraintAttributeMap = [:]
    open var headerState: ScrollViewHeaderState{
        switch visibleHeaderHeight{
        case -UIScreen.screenHeight...collapsedHeaderHeight:
            return .collapsed
        case collapsedHeaderHeight..<expandedHeight:
            return .transitioning
        case expandedHeight:
            return .expanded
        case expandedHeight...UIScreen.screenHeight:
            return .stretched
        default:
            assertionFailure("Unhandled range")
            return .collapsed
        }
    }
    
    open var subheaderView: UIView?
    open lazy var subheaderBackgroundView: UIView = UIView()
    var subheaderBackgroundViewConstraints: ConstraintAttributeMap = [:]
    open var subheaderCollapses: Bool = true
    
    open var headerLayoutView: UIView = UIView()
    open var headerBackgroundImageView: BaseImageView = BaseImageView()
    open var headerLabel: UILabel = UILabel().then { (label) in
        label.wrapWords()
    }
    var backgroundViewConstraints: ConstraintAttributeMap = [:]
    
    public var offset: CGFloat{
        return scrollView.contentOffset.y + scrollView.contentInset.top
    }
    
    public var headerHeightRange: CGFloat{
        return expandedHeight - collapsedHeaderHeight
    }
    
    public var percentCollapsed: CGFloat{
        let value = (expandedHeight - visibleHeaderHeight)/headerHeightRange
        return value.clamped(0.0, 1.0)
    }
    
    public var percentExpanded: CGFloat{
        return visibleHeaderHeight/expandedHeight
    }
    
    public var visibleHeaderHeight: CGFloat{
        return (expandedHeight - offset).clamped(collapsedHeaderHeight, expandedHeight)
    }
    
    
    func setupBehaviors(){
        behaviors.forEach { (behavior) in
            behavior.scrollViewHeader = self
            
        }
    }
    
    public required init(autoExpandingContentView: UIView, width: CGFloat, collapsedHeaderHeight: CGFloat = 0.0, subheaderView: UIView? = nil, behaviors: [ScrollViewHeaderBehavior] = []) {
        
        self.collapsedHeaderHeight = collapsedHeaderHeight
        autoExpandingContentView.layoutDynamicHeight(forWidth: width)
        self.expandedHeaderHeight = autoExpandingContentView.frame.h
        self.subheaderView = subheaderView
//                print("subheaderView.h: \(subheaderView?.h)")
//                print("expandedHeaderHeight: \(expandedHeaderHeight)")
//                print("collapsedHeaderHeight: \(collapsedHeaderHeight)")
        self.behaviors = behaviors
        super.init(frame: .zero)
        self.setupBehaviors()
    }
    
    public required init(expandedHeaderHeight: CGFloat, collapsedHeaderHeight: CGFloat = 0.0, subheaderView: UIView? = nil, behaviors: [ScrollViewHeaderBehavior] = []) {
        self.collapsedHeaderHeight = collapsedHeaderHeight
        self.expandedHeaderHeight = expandedHeaderHeight
        self.subheaderView = subheaderView
        self.behaviors = behaviors
        super.init(frame: .zero)
        self.setupBehaviors()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func createSubviews() {
        super.createSubviews()
        headerLayoutView.addSubview(headerBackgroundImageView)
        headerLayoutView.insertSubview(headerLabel, aboveSubview: headerBackgroundImageView)
        addSubview(headerLayoutView)
        headerLayoutView.frame = self.bounds
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
        headerLabel.forceSuperviewToMatchContentSize(insetBy: LayoutPadding(20))
        subheaderBackgroundViewConstraints.update(with: subheaderBackgroundView.equal(to: edges.excluding(.top)))
        subheaderBackgroundViewConstraints.update(with: subheaderBackgroundView.top.equal(to: headerLayoutView.bottom))
        subheaderView?.forceSuperviewToMatchContentSize()
        subheaderView?.forceAutolayoutPass()
    }
    open override func didInit() {
        super.didInit()
        clipsToBounds = true
        headerBackgroundImageView.contentMode = .scaleAspectFill
    }
    
    open func setupScrollViewRelatedConstraints(){
        let initialInsetTop = scrollView.contentInset.top

        viewConstraints.update(with: width.equal(to: scrollView.width))
        viewConstraints.update(with: top.equal(to: scrollView.top.inset(initialInsetTop)))
        viewConstraints.update(with: centerX.equal(to: scrollView.centerX))
        headerLayoutHeightConstraint = headerLayoutView.height.equal(to: expandedHeight)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        adjustViews(for: scrollView.contentOffset)
    }
    
    
    open override func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        setNeedsLayout()
    }
    
    let parallaxFactor: CGFloat = 0.3
    
    open func adjustViews(for scrollViewOffset: CGPoint) {
        var topConstant = -scrollView.contentInset.top
        if(visibleHeaderHeight <= collapsedHeaderHeight){
            topConstant = scrollViewOffset.y + collapsedHeaderHeight - expandedHeight
        }
        viewConstraints[.top]?.first?.constant = topConstant

        behaviors.forEach { (behavior) in
            behavior.adjustViews(for: self)
        }
        
//        printViewConstraints()
//        debugPrintDescription()
    }
    
    func resetBackgroundViewSizeConstraints(){
        backgroundViewConstraints[.width]?.first?.constant = 0.0
        backgroundViewConstraints[.height]?.first?.constant = 0.0
    }
    
//    func debugPrintDescription(){
//        print("frame \(self.frame)")
//        print("image frame: \(headerBackgroundImageView.frame)")
//
//        print("Header state: \(headerState)")
//        print("Offset: \(offset)")
//        print("VisibleHeaderHeight \(visibleHeaderHeight)")
//        print("ExpandedHeight: \(expandedHeight)")
//        print("ExpandedHeaderHeight: \(expandedHeaderHeight)")
//        print("SubheaderHeight: \(subheaderBackgroundView.frame.h)")
//        print("Percent collapsed: \(percentCollapsed)")
//        print("Percent expanded: \(percentExpanded)")
//        printSubheaderBackgroundViewConstraints()
//        printBackgroundViewConstraints()
//        printViewConstraints()
//    }
//
//    func printSubheaderBackgroundViewConstraints(){
//        print("Subheader backgroundview constriants")
//        print("height: \(String(describing: subheaderBackgroundViewConstraints[.height]?.constant))")
//        print("top: \(String(describing: subheaderBackgroundViewConstraints[.top]?.constant))")
//    }
//
//    func printBackgroundViewConstraints(){
//        print("Background constriants")
//        print("centerX: \(String(describing: backgroundViewConstraints[.centerX]?.constant))")
//        print("centerY: \(String(describing: backgroundViewConstraints[.centerY]?.constant))")
//        print("width: \(String(describing: backgroundViewConstraints[.width]?.constant))")
//        print("height: \(String(describing: backgroundViewConstraints[.height]?.constant))")
//    }
//
//    func printViewConstraints(){
//
//        print("View constraints")
//        print("centerX: \(String(describing: viewConstraints[.centerX]?.constant))")
//        print("top: \(String(describing: viewConstraints[.top]?.constant))")
//        print("width: \(String(describing: viewConstraints[.width]?.constant))")
//        print("headerLayoutHeightConstraint: \(String(describing: headerLayoutHeightConstraint?.constant))")
//    }

}
