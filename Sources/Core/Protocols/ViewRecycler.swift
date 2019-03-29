//
//  ViewRecycler.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKit

@objc public protocol ViewRecycler {
    @objc optional func registerReusables()
}

extension UITableViewController: ViewRecycler {}
extension UICollectionViewController: ViewRecycler {}
