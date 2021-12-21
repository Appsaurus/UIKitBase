//
//  Int+IndexPath.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 3/9/19.
//

import Foundation

public extension Int {
    var indexPath: IndexPath {
        return IndexPath(integerLiteral: self)
    }
}
