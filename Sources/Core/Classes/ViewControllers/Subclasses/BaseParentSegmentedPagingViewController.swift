//
//  BaseParentSegmentedPagingViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/11/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Foundation
import UIKit


open class BaseParentSegmentedPagingViewController: BaseParentPagingViewController{
    lazy open var segmentedControl: UISegmentedControl = {
        return UISegmentedControl(items: self.segmentedControlTitles())
    }()

    open var blendsSegmentedHeaderWithNavigationBar: Bool{
        return true
    }

    override open func createSubviews() {
        super.createSubviews()
        segmentedControl.addAction{ [weak self] (control: UISegmentedControl) in
            self?.transitionToPage(at: control.selectedSegmentIndex)
        }
    }

    override open func createHeaderView() -> UIView? {
        let header = UIView()
        header.addSubview(segmentedControl)
        if blendsSegmentedHeaderWithNavigationBar{
            header.backgroundColor = navigationController?.navigationBar.barTintColor
        }
        return header
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if blendsSegmentedHeaderWithNavigationBar{
//            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//            navigationController?.navigationBar.shadowImage = UIImage()
        }
        segmentedControl.selectedSegmentIndex = initialPageIndex
    }

    open override func createAutoLayoutConstraints() {

        super.createAutoLayoutConstraints()
        segmentedControl.edges.equal(to: .inset(8.0, 5.0))
    }

    open func segmentedControlTitles() -> [String]{
        return []
    }

    open override func transitionToPage(at index: Int) {
        super.transitionToPage(at: index)
        segmentedControl.selectedSegmentIndex = index
    }

    open override func didPage(from page: Int?, to nextPage: Int?) {
        super.didPage(from: page, to: page)
        guard let nextPage = nextPage else { return }
        segmentedControl.selectedSegmentIndex = nextPage
    }

    open override func didCancelPaging(from page: Int?, to nextPage: Int?) {
        super.didCancelPaging(from: page, to: nextPage)
        guard let page = page else { return }
        segmentedControl.selectedSegmentIndex = page
    }
}

