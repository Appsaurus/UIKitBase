//
//  StretchyHeaderView.swift
//  Pods
//
//  Created by Brian Strobach on 4/13/17.
//
//

import Foundation
import ObjectiveC
import UIKit
import DarkMagic
// MARK: - UIScrollView Extension

public protocol ScrollViewHeaderAdornable: AnyObject {
    associatedtype SVH: ScrollViewHeader
    var scrollView: UIScrollView { get }
    var scrollViewHeader: SVH? { get set }
    func createScrollViewHeader() -> SVH
    func setupScrollViewHeader()
}

private var scrollViewHeaderKey: UInt8 = 0
public extension ScrollViewHeaderAdornable where Self: NSObject {
    var scrollViewHeader: SVH? {
        get {
            
            return getAssociatedObject(for: &scrollViewHeaderKey, with: .weak)
        }
        set {
            setAssociatedObject(newValue, for: &scrollViewHeaderKey, with: .weak)
        }
    }

    func setupScrollViewHeader() {
        self.addScrollViewHeader(createScrollViewHeader())
    }

    func addScrollViewHeader(_ scrollViewHeader: SVH) {
        scrollViewHeader.setupObserver(for: scrollView)
        scrollView.addSubview(scrollViewHeader)
        scrollView.bringSubviewToFront(scrollViewHeader)
        scrollViewHeader.setupScrollViewRelatedConstraints()
        scrollViewHeader.forceAutolayoutPass()
        //        for view in scrollView.subviews{
        //            view.frame.y += scrollViewHeader.expandedHeight
        //        }
        self.scrollViewHeader = scrollViewHeader

        scrollViewHeader.onBoundsChange = { [weak self] _ in
            DispatchQueue.main.async {
                self?.headerContentDidChange()
            }
        }

        self.headerContentDidChange()
    }

    // Called whenever changes are made that could effect the height of the header
    func headerContentDidChange() {
        self.adjustContentPositionToAccomodateHeaderHeight()
    }

    func adjustContentPositionToAccomodateHeaderHeight() {
        guard let scrollViewHeader = scrollViewHeader else { return }
        if scrollView.contentInset.top < scrollViewHeader.expandedHeight {
            scrollView.contentInset.top = scrollViewHeader.expandedHeight
            scrollView.contentOffset.y = -scrollViewHeader.expandedHeight
        }
    }

    func removeScrollViewHeader() {
        self.scrollViewHeader?.clearObservations()
        self.scrollViewHeader?.removeFromSuperview()
        self.scrollViewHeader = nil
    }
}

public extension ScrollViewHeaderAdornable where Self: UITableViewController {
    var scrollView: UIScrollView {
        return tableView
    }
}

public extension ScrollViewHeaderAdornable where Self: UICollectionViewController {
    var scrollView: UIScrollView {
        return collectionView!
    }
}

// extension BaseScrollviewController: ScrollViewHeaderAdornable{
public extension ScrollViewHeaderAdornable where Self: BaseScrollviewController {
    func setupScrollViewHeader() {
        self.addScrollViewHeader(createScrollViewHeader())
        self.headerContentDidChange() // Get initial layout
    }

    // Called whenever changes are made that could effect the height of the header
    func headerContentDidChange() {
        guard let header = scrollViewHeader else { return }
        view.forceAutolayoutPass()
        var contentSize = view.bounds.size
        contentSize.height -= header.collapsedHeaderHeight
        self.scrollView.contentSize = contentSize
        scrollViewContentView.frame.size = contentSize
        self.adjustContentPositionToAccomodateHeaderHeight()
    }
}

public enum ScrollViewHeaderState {
    case collapsed, expanded, transitioning, stretched
}
