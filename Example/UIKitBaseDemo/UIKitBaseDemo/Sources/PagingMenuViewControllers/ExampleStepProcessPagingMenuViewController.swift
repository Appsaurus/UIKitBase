//
//  ExampleStepProcessPagingMenuViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 2/20/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIKitBase
import UIKit
import Swiftest

public class ExampleStepProcessPagingMenuViewController: StepProcessPagingMenuViewController {

    override open func createPagedViewControllers() -> [UIViewController] {
        return self.stepViewControllers
    }


    internal lazy var stepViewControllers: [ExampleStepViewController] = {
        var pages: [ExampleStepViewController] = []
        stepModels.count.times {
            pages.append(ExampleStepViewController())
        }
        return pages
    }()

    open override func initProperties() {
        super.initProperties()
        automaticallyPageToNextStep = true
        stepModels = {
            let firstStep = StepProcessMenuStepViewModel(stepTitle: "Do first\nthing")
            let secondStep = StepProcessMenuStepViewModel(stepTitle: "Do second\nthing")
            let thirdStep = StepProcessMenuStepViewModel(stepTitle: "Do first\nthing first")
            let fourthStep = StepProcessMenuStepViewModel(stepTitle: "And\nthis")
            thirdStep.prerequisiteSteps = [firstStep]
            return [firstStep, secondStep, thirdStep, fourthStep]
        }()
    }

	open override func setupControlActions() {
		super.setupControlActions()
		for (index, vc) in stepViewControllers.enumerated(){
			vc.taskSwitch.addAction(events: [.valueChanged], action: { [weak self] in
				guard let `self` = self else { return }
				self.completeStep(at: index, isComplete: vc.taskSwitch.isOn)
			})
		}
	}

    public override func createSubviews() {
        super.createSubviews()
    }

	//PagingMenuControllerDelegate

	open override func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
		return [StepProcessPagingMenuItemCell.self]
	}
}

open class ExampleStepViewController: ExamplePagedViewController{
	let taskSwitch: UISwitch = UISwitch()

	open override func createSubviews() {
		super.createSubviews()
		view.addSubview(taskSwitch)
	}

	open override func createAutoLayoutConstraints() {
		super.createAutoLayoutConstraints()
		taskSwitch.centerInSuperview()
	}
}
