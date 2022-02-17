//
//  ExampleDeepLinkDestinationViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 1/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKitBase

class ExampleDeepLinkDestinationViewController: BaseViewController{
	var id: String

	public required init(id: String) {
		self.id = id
        super.init(callInitLifecycle: true)
    }

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
