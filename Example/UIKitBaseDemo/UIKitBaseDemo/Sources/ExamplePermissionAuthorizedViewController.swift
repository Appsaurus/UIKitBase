//
//  ExamplePermissionAuthorizedViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 1/26/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIKitBase

public class ExamplePermissionAuthorizedViewController: BaseViewController{
	public override func createStatefulViews() -> StatefulViewMap {
		return .default
	}

    open override func initProperties() {
        super.initProperties()
        self.initialState = .empty
    }
        
    public override func customizeStatefulViews() {
		super.customizeStatefulViews()
		emptyView()?.set(message: "Awwww yeah. You has permissions.")
	}

}
