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
    open lazy var segmentedControl: UISegmentedControl = {
        UISegmentedControl(items: self.segmentedControlTitles())
    }()

    open var blendsSegmentedHeaderWithNavigationBar: Bool {
        return true
    }

    override open func createSubviews() {
        super.createSubviews()
        self.segmentedControl.addAction { [weak self] (control: UISegmentedControl) in
            self?.transitionToPage(at: control.selectedSegmentIndex)
        }
    }

    override open func createHeaderView() -> UIView? {
        let header = UIView()
        header.addSubview(self.segmentedControl)
        if self.blendsSegmentedHeaderWithNavigationBar {
            header.backgroundColor = navigationController?.navigationBar.barTintColor
        }
        return header
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if self.blendsSegmentedHeaderWithNavigationBar {
//            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//            navigationController?.navigationBar.shadowImage = UIImage()
        }
        self.segmentedControl.selectedSegmentIndex = initialPageIndex
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.segmentedControl.edges.equal(to: .inset(8.0, 5.0))
    }

    open func segmentedControlTitles() -> [String] {
        return []
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
