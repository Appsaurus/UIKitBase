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

// MARK: - UIScrollView Extension

public protocol ScrollViewHeaderAdornable: AnyObject {
    associatedtype SVH: ScrollViewHeader
    var scrollView: UIScrollView { get }
    func createScrollViewHeader() -> SVH
    func setupScrollViewHeader()
}

private var scrollViewHeaderKey: UInt8 = 0
public extension ScrollViewHeaderAdornable where Self: NSObject {
    var scrollViewHeader: SVH? {
        get {
            return getAssociatedObject(for: &scrollViewHeaderKey)
        }
        set {
            setAssociatedObject(newValue, for: &scrollViewHeaderKey)
        }
    }

    func setupScrollViewHeader() {
        addScrollViewHeader(createScrollViewHeader())
    }

    func addScrollViewHeader(_ scrollViewHeader: SVH) {
        scrollViewHeader.setupObserver(for: scrollView)
        scrollView.addSubview(scrollViewHeader)
        scrollView.bringSubviewToFront(scrollViewHeader)
        if let refresh = scrollView.refreshControl {
            scrollView.bringSubviewToFront(refresh)
            refresh.frame.y += scrollViewHeader.expandedHeight
        }
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

        headerContentDidChange()
    }

    // Called whenever changes are made that could effect the height of the header
    func headerContentDidChange() {
        adjustContentPositionToAccomodateHeaderHeight()
    }

    func adjustContentPositionToAccomodateHeaderHeight() {
        guard let scrollViewHeader = scrollViewHeader else { return }
        if scrollView.contentInset.top < scrollViewHeader.expandedHeight {
            scrollView.contentInset.top = scrollViewHeader.expandedHeight
            scrollView.contentOffset.y = -scrollViewHeader.expandedHeight
        }
    }

    func removeScrollViewHeader() {
        scrollViewHeader?.clearObservations()
        scrollViewHeader?.removeFromSuperview()
        scrollViewHeader = nil
    }
}

extension ScrollViewHeaderAdornable where Self: UITableViewController {
    public var scrollView: UIScrollView {
        return tableView
    }
}

extension ScrollViewHeaderAdornable where Self: UICollectionViewController {
    public var scrollView: UIScrollView {
        return collectionView!
    }
}

// extension BaseScrollviewController: ScrollViewHeaderAdornable{
extension ScrollViewHeaderAdornable where Self: BaseScrollviewController {
    public func setupScrollViewHeader() {
        addScrollViewHeader(createScrollViewHeader())
        headerContentDidChange() // Get initial layout
    }

    // Called whenever changes are made that could effect the height of the header
    public func headerContentDidChange() {
        guard let header = scrollViewHeader else { return }
        view.forceAutolayoutPass()
        var contentSize = view.bounds.size
        contentSize.height -= header.collapsedHeaderHeight
        //        scrollView.contentSize = contentSize
        scrollViewContentView.frame.size = contentSize
        adjustContentPositionToAccomodateHeaderHeight()
    }
}

public enum ScrollViewHeaderState {
    case collapsed, expanded, transitioning, stretched
}
