//
//  UIViewController+ShowActivityState.swift
//  GiftAMeal
//
//  Created by Brian Strobach on 12/16/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIKit

public extension UIViewController {
    func showActivityState(from button: BaseButton) {
        button.state = .activity
        view.endEditing(true)
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
    }

    func endActivityState(from button: BaseButton) {
        button.state = .normal
        view.isUserInteractionEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }

    func showActivityState(from button: UIButton) {
        button.showActivityIndicator()
        view.endEditing(true)
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
    }

    func endActivityState(from button: UIButton) {
        button.hideActivityIndicator()
        view.isUserInteractionEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
}
