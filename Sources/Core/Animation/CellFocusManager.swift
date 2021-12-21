//
//  CellFocusManager.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import DarkMagic
import Foundation
import UIKitBase
public protocol CellFocusManaged: AnyObject {
    func addCellFocus(behaviors: [CellFocusAnimationBehavior], to scrollView: UIScrollView, focusedIn focusLocation: CellFocusLocation)
}

private extension AssociatedObjectKeys {
    static let cellFocusManagerAssociated = AssociatedObjectKey<CellFocusManager>("cellFocusManagerAssociated")
}

public extension CellFocusManaged where Self: NSObject {
    var cellFocusManager: CellFocusManager? {
        get {
            return self[.cellFocusManagerAssociated]
        }
        set {
            self[.cellFocusManagerAssociated] = newValue
        }
    }

    func addCellFocus(behaviors: [CellFocusAnimationBehavior], to scrollView: UIScrollView, focusedIn focusLocation: CellFocusLocation) {
        self.cellFocusManager = CellFocusManager(scrollView: scrollView, behaviors: behaviors, focusLocation: focusLocation)
    }
}

open class CellFocusManager: NSObject, ScrollViewObserver {
    public var behaviors: [CellFocusAnimationBehavior] = []
    open var focusLocation: CellFocusLocation!

    public init(scrollView: UIScrollView, behaviors: [CellFocusAnimationBehavior], focusLocation: CellFocusLocation) {
        super.init()
        setupObserver(for: scrollView)
        self.behaviors = behaviors
        self.focusLocation = focusLocation
    }

    public func scrollViewObserverDidObserveScroll(of scrollView: UIScrollView, to offset: CGPoint) {
        let cells: [UIView] = (scrollView as? UITableView)?.visibleCells ?? (scrollView as? UICollectionView)?.visibleCells ?? []
        for cell in cells {
            for behavior in self.behaviors {
                let focus = self.percentFocused(cell: cell, scrollView: scrollView, focusLocation: behavior.focusLocation ?? self.focusLocation)
                behavior.adjust(cell: cell, for: focus)
            }
        }
    }

    func percentFocused(cell: UIView, scrollView: UIScrollView, focusLocation: CellFocusLocation) -> CGFloat {
        let cellY = cell.frame.center.x - scrollView.contentOffset.x // cell.frame.center.y - scrollView.contentOffset.y
        let topEaseRange = focusLocation.easeOutMin ... focusLocation.focusRange.lowerBound
        let bottomEaseRange = focusLocation.focusRange.upperBound ... focusLocation.easeOutMax
        switch cellY {
        case -999_999.0 ..< focusLocation.easeOutMin:
            return 0.0
        case topEaseRange:
            return 1.0 - self.normalizedPercent(of: topEaseRange, value: cellY)
        case focusLocation.focusRange:
            return 1.0
        case bottomEaseRange:
            return self.normalizedPercent(of: bottomEaseRange, value: cellY)
        case focusLocation.easeOutMax ... 999_999.0:
            return 0.0
        default:
            return 1.0
        }
    }

    func normalizedPercent(of range: ClosedRange<CGFloat>, value: CGFloat) -> CGFloat {
        let rangeValue = range.upperBound - range.lowerBound
        return (range.upperBound - value) / rangeValue
    }
}

open class CellFocusLocation {
    public var easeOutMin: CGFloat // Cell "focus" will be eased out between focusRange top and this point
    public var focusRange: ClosedRange<CGFloat> // Cell will be 100% "focused" in this range
    public var easeOutMax: CGFloat // Cell "focus" will be eased out between focusRange bottom and this point

    public init(easeOutMin: CGFloat, focusRange: ClosedRange<CGFloat>, easeOutMax: CGFloat) {
        self.easeOutMin = easeOutMin
        self.focusRange = focusRange
        self.easeOutMax = easeOutMax
    }
}

open class CellFocusAnimationBehavior {
    open var focusLocation: CellFocusLocation?

    open func adjust(cell: UIView, for percentFocused: CGFloat) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }
}

open class CellFocusAlphaBehavior: CellFocusAnimationBehavior {
    override open func adjust(cell: UIView, for percentFocused: CGFloat) {
        cell.alpha = percentFocused
    }
}

open class CellFocusScaleBehavior: CellFocusAnimationBehavior {
    override open func adjust(cell: UIView, for percentFocused: CGFloat) {
        let scale = max(0.8, percentFocused)
        cell.layer.transform = CATransform3DMakeScale(scale, scale, scale)
    }
}

extension CellFocusManaged where Self: UITableViewController {
    var scrollView: UIScrollView {
        return tableView
    }
}
