//
//  ContainerScrollView.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKit
import Swiftest
import Actions
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
            if hasReachedTopOfContent {
                
            }
            if hasReachedBottomOfContent {
                bounces = false  //To let inner scrollview bounce instead
            } else {
                bounces = true
            }
            lastContentOffset = oldValue
        }
    }
    var contentView: UIView
    var recognizesParentScroll: Bool = true
    var bouncesBottom: Bool = false
    
    /// When an inner scroll hits content bounds, it will continue scrolling in the outer scrollview.
    /// For now this only scrolls to top until I can find a more seameless velocity/pan based approch.
    var transfersInertiaBetweenScrollViews: Bool = true
    
    public required init(contentView: UIView = UIView()) {
        self.contentView = contentView
        super.init(frame: .zero)
        addSubview(contentView)
        didInitProgramatically()
    }
    
    open override func didInit() {
        super.didInit()
        showsVerticalScrollIndicator = false
        bounces = false
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentSize = contentView.frame.size
    }
    
    var childScrollViews: Set<UIScrollView> = Set<UIScrollView>()
    //    var observers: [KeyValueObserver] = []
    func catpureDelegateIfNeeded(scrollView: UIScrollView) {
        guard !childScrollViews.contains(scrollView) else { return }
        childScrollViews.update(with: scrollView)
        scrollView.delegate = self //TODO: implement delegate splitter so that we don't have to hijack this
        
        //WIP: Investigating velocity transfer of scroll
        //        scrollView.panGestureRecognizer.onRecognition {
        //            let innerScrollViewPanGestureRecognizer = scrollView.panGestureRecognizer
        //            switch scrollView.panGestureRecognizer.state {
        //            case .ended:
        //                print("otherstate: ended)")
        //                print("innerScrollView position: \(scrollView.yOffsetPosition)")
        //                print("other scroll: \(self.pointer(scrollView))")
        //                print("Other vel \(innerScrollViewPanGestureRecognizer.velocity(in: self).y)")
        //                print("Other translation \(innerScrollViewPanGestureRecognizer.translation(in: self).y)")
        //                print("Other offset for top \(scrollView.verticalOffsetForTop)")
        //                print("Other offset \(scrollView.contentOffset.y)")
        //                let distance = scrollView.verticalOffsetForTop - scrollView.contentOffset.y
        //                print("Distance \(distance)")
        ////                scrollView.panGestureRecognizer.setTranslation(_ translation: CGPoint, in view: UIView?)
        //
        //
        //            case .began:
        //                print("otherstate: began)")
        //                print("Other offset for top \(scrollView.verticalOffsetForTop)")
        //                print("Other offset \(scrollView.contentOffset.y)")
        //            case .cancelled:
        //                print("otherstate: cancelled)")
        //            case .failed:
        //                print("otherstate: failed)")
        //            case .possible:
        //                print("otherstate: possible)")
        //            case .changed:
        ////                print("otherstate: changed)")
        //                break
        //            default:
        //                print("otherstate: default)")
        //                break
        //            }
        //        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let innerScrollViewPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
            let innerScrollView = innerScrollViewPanGestureRecognizer.view as? UIScrollView else { return false }
        guard innerScrollView.isDescendant(of: contentView) && (innerScrollView is UITableView || innerScrollView is UICollectionView) else { return false }
        
        catpureDelegateIfNeeded(scrollView: innerScrollView)
        
        if innerScrollViewPanGestureRecognizer.velocity(in: self).y < 0 && innerScrollView.hasReachedBottomOfContent && !bounces {
            //Reached bottom of inner scrollview
            return false
        }
        
        if innerScrollViewPanGestureRecognizer.velocity(in: self).y > 0  && innerScrollView.hasReachedTopOfContent {
            //Simultaneously recognizing gestures, has reached top of content
            return true
        }
        
        if yOffsetPosition == .bottom && !innerScrollView.hasReachedTopOfContent {
            //Disbling simultaneous gestures, outer scroll hit bottom and inner scroll has not reached top.
            return false
        }
        
        return true
    }
    
    public func pointer(_ reference: AnyObject) -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(reference).toOpaque()
    }
    
}

extension ContainerScrollView: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if transfersInertiaBetweenScrollViews && scrollView != self {
            let position = scrollView.calculateYOffsetPostition(for: targetContentOffset.pointee.y)
            switch position {
            case .top, .bouncingTop:
                if velocity.y < 0 { self.scrollToTop() }
            case .bottom, .bouncingBottom:
                if velocity.y > 0 { self.scrollToBottom() }
            default: break
            }
        }
    }
}
