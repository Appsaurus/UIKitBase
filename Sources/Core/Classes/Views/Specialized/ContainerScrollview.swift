//
//  ContainerScrollView.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Actions
import Swiftest
import UIKit
open class ContainerScrollView: BaseScrollView, UIGestureRecognizerDelegate {
    open var lastContentOffset: CGPoint = .zero {
        didSet {
            if contentOffset.y < lastContentOffset.y {
                //                print("Scrolled down")
            } else if contentOffset.y > lastContentOffset.y {
                //                print("Scrolled up")
            }
        }
    }

    open override var contentOffset: CGPoint {
        didSet {
            if hasReachedTopOfContent {}
            if hasReachedBottomOfContent {
                bounces = false // To let inner scrollview bounce instead
            } else {
                bounces = true
            }
            lastContentOffset = oldValue
        }
    }

    var contentView: UIView
    var recognizesParentScroll: Bool = true
    var bouncesBottom: Bool = false

    public required init(contentView: UIView = UIView()) {
        self.contentView = contentView
        super.init(frame: .zero)
        addSubview(contentView)
    }

    open override func initProperties() {
        super.initProperties()
        showsVerticalScrollIndicator = false
        bounces = false
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentSize = contentView.frame.size
    }

    var childScrollViews: Set<UIScrollView> = Set<UIScrollView>()
    //    var observers: [KeyValueObserver] = []

    func captureScrollViewIfNeeded(scrollView: UIScrollView) {
        guard !childScrollViews.contains(scrollView) else { return }
        childScrollViews.update(with: scrollView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let innerScrollViewPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
            let innerScrollView = innerScrollViewPanGestureRecognizer.view as? UIScrollView else { return false }
        guard innerScrollView.isDescendant(of: contentView), innerScrollView is UITableView || innerScrollView is UICollectionView else { return false }

        captureScrollViewIfNeeded(scrollView: innerScrollView)

        if innerScrollViewPanGestureRecognizer.velocity(in: self).y < 0, innerScrollView.hasReachedBottomOfContent, !bounces {
            // Reached bottom of inner scrollview
            return false
        }

        if innerScrollViewPanGestureRecognizer.velocity(in: self).y > 0, innerScrollView.hasReachedTopOfContent {
            // Simultaneously recognizing gestures, has reached top of content
            return true
        }

        if yOffsetPosition == .bottom, !innerScrollView.hasReachedTopOfContent {
            // Disbling simultaneous gestures, outer scroll hit bottom and inner scroll has not reached top.
            return false
        }

        return true
    }

    public func pointer(_ reference: AnyObject) -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(reference).toOpaque()
    }
}

// extension ContainerScrollView: UIScrollViewDelegate {
//    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if transfersInertiaBetweenScrollViews, scrollView != self {
//            let position = scrollView.calculateYOffsetPostition(for: targetContentOffset.pointee.y)
//            switch position {
//            case .top, .bouncingTop:
//                if velocity.y < 0 { scrollToTop() }
//            case .bottom, .bouncingBottom:
//                if velocity.y > 0 { scrollToBottom() }
//            default: break
//            }
//        }
//    }
// }
