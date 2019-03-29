//
//  BaseButtonExamplesViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 10/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIKitBase

open class BaseButtonExamplesViewController: BaseStackViewController{
    

//    open override lazy var initialArrangedSubviews: [UIView] = []// self.createButtons()

    open override func didInit() {
        super.didInit()
        stackView.alignment = .center
    }
    
//    open func createButtons() -> [UIButton]{
//        var buttons: [BaseUIButton] = []
//        5.times {
//            let button = BaseUIButton()
////            button.apply(buttonStyle: currentStyle.boldPrimaryContrastButtonStyle())
//
//            button.backgroundColor = .blue
//            button.setTitleColor(.white, for: .normal)
//            button.setTitleColor(.orange, for: .highlighted)
//            button.setTitleColor(.yellow, for: .loading)
//            button.setTitleColor(.red, for: .error)
//            button.setTitleColor(.brown, for: .disabled)
//
//            button.setTitle("Normal", for: .normal)
//            button.setTitle("Selected", for: .selected)
//            button.setTitle("Error", for: .error)
//            button.setTitle("Disabled", for: .disabled)
//            buttons.append(button)
//            button.imageView?.setFontIconImage(MaterialIcons.random())
//
//            button.tapActionMap = [
//                UIControlState.normal.rawValue : {self.doNormalStuff(button)},
//                UIControlState.selected.rawValue : {self.doSelectedStuff(button)},
//                UIControlState.disabled.rawValue : {self.doDisabledStuff(button)},
//                UIControlState.error.rawValue : {self.doErrorStuff(button)}
//            ]
//        }
//        buttons.last?.isEnabled = false
//
//        return buttons
//    }
//
//    func doNormalStuff(_ button: BaseUIButton){
//        makeCall(for: button, chanceOfSuccess: 100)
//        print("Normal **************************+")
//    }
//
//    func doDisabledStuff(_ button: BaseUIButton){
//        makeCall(for: button, chanceOfSuccess: 0)
//        print("Disabled **************************+")
//    }
//
//    func doSelectedStuff(_ button: BaseUIButton){
//        makeCall(for: button, chanceOfSuccess: 50)
//        print("Selected **************************+")
//    }
//
//    func doErrorStuff(_ button: BaseUIButton){
//        makeCall(for: button, chanceOfSuccess: 50)
//        print("error **************************+")
//    }
//
//    func makeCall(for button: BaseUIButton, chanceOfSuccess: Int){
//            button.isLoading = true
//            Placeholder.makeFakeNetworkCall(delay: 2, chanceOfSuccess: chanceOfSuccess, success: {
//                button.isSelected.toggle()
//            }, failure: {
//                button.isError = true
//            })
//    }
}

