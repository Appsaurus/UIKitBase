//
//  ScrollViewReferencing.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/3/20.
//  Copyright © 2020 Brian Strobach. All rights reserved.
//

import UIKit

public protocol ScrollViewReferencing {
    var scrollView: UIScrollView { get }
}

extension UITableViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return tableView
    }
}

extension UICollectionViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return collectionView!
    }
}

extension BaseContainedTableViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return tableView
    }
}

extension BaseContainedCollectionViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return collectionView
    }
}
