//
//  ExampleUIViewControllerMixinable.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 11/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKitBase
import Swiftest
import UIKitMixinable
import UIKitTheme
import UIKitBase
import Layman

open class ExampleUIViewMixinable: MixinableView{
    open override func createMixins() -> [LifeCycle] {
        return [StyleableViewMixin(self)]
    }
}
extension ExampleUIViewMixinable: Styleable{
    public func style() {
        self.backgroundColor = .red
    }
}

extension ExampleUIViewControllerMixinable:
KeyboardSizeAware
& NavigationBarStyleable {}

open class ExampleUIViewControllerMixinable: MixinableViewController{
    
    let textField = UITextField()
    let mixedView = ExampleUIViewMixinable()
    
    open override func createMixins() -> [LifeCycle] {
        return [KeyboardSizeAwareMixin(self),
                NavigationBarStyleableMixin(self),
                StyleableViewControllerMixin(self)]
    }
    
    public var keyboardHeight: CGFloat?{
        didSet{
            debugLog(keyboardHeight ?? "No value for height.")
        }
    }
    
    open override func didInit() {
        super.didInit()
        navigationBarStyle = .transparent
        extendViewUnderNavigationBar()
    }
    
    open override func createSubviews() {
        super.createSubviews()
        view.addSubviews(textField, mixedView)
    }
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        textField.centerInSuperview()
        textField.width.equal(to: 50%)
        textField.height.equal(to: 50)
        mixedView.size.equal(to: textField)
        mixedView.bottom.equal(to: textField.top)
        mixedView.centerX.equalToSuperview()        
    }
    
}

//MARK: Swizzling example
//open class ExampleUIViewControllerMixinable: UIViewController{
//
//    @objc open override func createMixins() -> [UIViewControllerLifeCycle] {
//        return [KeyboardMixin(viewController: self)]
//    }
//
//    public var keyboardHeight: CGFloat?{
//        didSet{
//            debugLog(keyboardHeight)
//        }
//    }
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        let textField = UITextField()
//        view.addSubview(textField)
//        textField.centerInSuperview()
//        textField.autoMatchWidthOfSuperview(multiplier: 0.5)
//        textField.autoSizeHeight(to: 50.0)
//    }
//}
//



extension ExampleUIViewControllerMixinable: Styleable{
    public func style() {
        self.view.backgroundColor = .primary
    }
}
