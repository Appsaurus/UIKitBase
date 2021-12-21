//
//  BaseParentSegmentedPagingViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/11/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Foundation
import UIKit

open class BaseParentSegmentedPagingViewController: BaseParentPagingViewController {
    public enum SegmentedControlPosition {
        case headerView
        case top
        case topRight
        case topLeft
        case bottom
        case bottomRight
        case bottomLeft
    }

    open var segmentedControlPosition: SegmentedControlPosition = .headerView

    open lazy var segmentedControl: UISegmentedControl = .init(items: self.segmentedControlItems())

    open var blendsSegmentedHeaderWithNavigationBar: Bool {
        return true
    }

    override open func createSubviews() {
        super.createSubviews()
        guard self.segmentedControlPosition != .headerView else {
            return
        }
        self.view.addSubview(self.segmentedControl)
    }

    override open func createHeaderView() -> UIView? {
        guard self.segmentedControlPosition == .headerView else {
            return nil
        }
        let header = UIView()
        header.addSubview(self.segmentedControl)
        if self.blendsSegmentedHeaderWithNavigationBar {
            header.backgroundColor = navigationController?.navigationBar.barTintColor
        }
        return header
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.selectedSegmentIndex = initialPageIndex
        self.segmentedControl.moveToFront()
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.createSegmentedControlAutoLayoutConstraints()
    }

    override open func setupControlActions() {
        super.setupControlActions()
        self.segmentedControl.addAction { [weak self] (control: UISegmentedControl) in
            self?.transitionToPage(at: control.selectedSegmentIndex)
        }
    }

    open func segmentedControlItems() -> [Any] {
        return []
    }

    open func createSegmentedControlAutoLayoutConstraints() {
        switch self.segmentedControlPosition {
        case .headerView:
            self.segmentedControl.edges.equal(to: .inset(8.0, 5.0))
        case .top:
            self.segmentedControl.top.equalToSuperviewMargin()
            self.segmentedControl.centerX.equalToSuperview()
        case .topRight:
            self.segmentedControl.topRight.equalToSuperviewMargin()
        case .topLeft:
            self.segmentedControl.topLeft.equalToSuperviewMargin()
        case .bottom:
            self.segmentedControl.bottom.equalToSuperviewMargin()
            self.segmentedControl.centerX.equalToSuperview()
        case .bottomRight:
            self.segmentedControl.bottomRight.equalToSuperviewMargin()
        case .bottomLeft:
            self.segmentedControl.bottomLeft.equalToSuperviewMargin()
        }
    }

    override open func transitionToPage(at index: Int) {
        super.transitionToPage(at: index)
        self.segmentedControl.selectedSegmentIndex = index
    }

    override open func didPage(from page: Int?, to nextPage: Int?) {
        super.didPage(from: page, to: page)
        guard let nextPage = nextPage else { return }
        self.segmentedControl.selectedSegmentIndex = nextPage
    }

    override open func didCancelPaging(from page: Int?, to nextPage: Int?) {
        super.didCancelPaging(from: page, to: nextPage)
        guard let page = page else { return }
        self.segmentedControl.selectedSegmentIndex = page
    }
}
