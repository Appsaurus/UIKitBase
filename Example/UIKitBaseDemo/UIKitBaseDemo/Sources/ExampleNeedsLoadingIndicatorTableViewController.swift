//
//  ExampleNeedsLoadingIndicatorTableViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 1/4/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIKitBase
import Actions
import SwiftyTimer

open class ExampleNeedsLoadingIndicatorTableViewController: ExamplePaginatableTableViewController{

	var autoLoadSwitch: UISwitch = UISwitch.init()
	lazy var timer: Timer = self.buildTimer()

    
	func buildTimer() -> Timer{
		return Timer.new(after: 10.seconds, { [weak self] in
			guard let `self` = self else { return }
			self.reloadOrShowNeedsLoadingIndicator(title: "NEW ITEMS", reloadTest: {
                
				guard !self.autoLoadSwitch.isOn else {
					return true
				}
				return AppDelegate.activityMonitor?.dormant == true
			})
		})
	}
	lazy var titleUpdater: Timer = Timer.every(100.ms, updateTitle)

	deinit {
		timer.invalidate()
		titleUpdater.invalidate()
	}

	open override func createSubviews() {
		super.createSubviews()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: autoLoadSwitch)
	}
	open override func startLoading() {
		super.startLoading()

		timer.start()
		titleUpdater.start()
	}

	open func updateTitle(){
		let timeLeft = timer.fireDate.timeIntervalSinceNow
		self.title = timeLeft > 0 ? String(timeLeft.rounded(numberOfDecimalPlaces: 1)) : "Times up!"
	}

	open override func didReload(){
		super.didReload()

		timer = buildTimer()
		timer.start()
	}




}
