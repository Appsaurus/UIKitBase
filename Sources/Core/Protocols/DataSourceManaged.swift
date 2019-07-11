//
//  DataSourceManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/22/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import DarkMagic
import Swiftest
import UIKit

// public protocol DataSourceManaged {
//    var dataSourceDelegate: DataSourceManagedDelegate { get set }
// }
//
// public class DataSourceManagedDelegate {
//    var sectionCount: ClosureOut<Int> = { 0 }
//    var numberOfItems: Closure<Int, Int> = { _ in 0 }
// }
//
// private extension AssociatedObjectKeys {
//    static let dataSourceDelegate = AssociatedObjectKey<DataSourceManagedDelegate>("dataSourceDelegate")
// }
//
// public extension DataSourceManaged where Self: NSObject {
//    var dataSourceDelegate: DataSourceManagedDelegate {
//        get {
//            return self[.dataSourceDelegate, DataSourceManagedDelegate()]
//        }
//        set {
//            self[.dataSourceDelegate] = newValue
//        }
//    }
// }
