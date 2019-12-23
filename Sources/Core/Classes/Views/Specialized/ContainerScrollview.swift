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

    public var contentView: UIView
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
//        print("contentView.frame.size: \(contentView.frame.size)")
        contentSize = contentView.frame.size
    }

    public var childScrollViews: Set<UIScrollView> = Set<UIScrollView>()
    //    var observers: [KeyValueObserver] = []

    func captureScrollViewIfNeeded(scrollView: UIScrollView) {
        guard !childScrollViews.contains(scrollView) else { return }
        childScrollViews.update(with: scrollView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }

        guard gestureRecognizers?.contains(pan) == true else { return true }

        guard let innerScrollViewPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
            let innerScrollView = innerScrollViewPanGestureRecognizer.view as? UIScrollView,
            innerScrollView.gestureRecognizers?.contains(innerScrollViewPanGestureRecognizer) == true else { return true }

        guard innerScrollView.isDescendant(of: contentView), innerScrollView is UITableView || innerScrollView is UICollectionView else { return true }

        captureScrollViewIfNeeded(scrollView: innerScrollView)

        if hasReachedBottomOfContent, !innerScrollView.hasReachedTopOfContent {
            return false
        }


        return true
    }

    public func pointer(_ reference: AnyObject) -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(reference).toOpaque()
    }
}

//extension UIPanGestureRecognizer {
//    var verticalScrollDirection: UIPanGestureVerticalScrollDirection {
//        switch velocity(in: view).y {
//            case 0: return .none
//            case 0...CGFloat.max: return .down
//            default: return .up
//
//        }
//    }
//}
//
//enum UIPanGestureVerticalScrollDirection {
//    case up
//    case down
//    case none
//}

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
