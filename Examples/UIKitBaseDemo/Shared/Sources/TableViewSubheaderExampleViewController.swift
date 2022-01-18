//
//  TableViewSubheaderExampleViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitBase
import UIKit

open class TableViewSubheaderExampleViewController: TableViewHeaderExampleViewController{
    override open func createSubheaderView() -> UIView?{
        return createExampleSubheaderView()
    }
}
