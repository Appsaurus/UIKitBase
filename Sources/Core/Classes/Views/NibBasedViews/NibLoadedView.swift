//
//  NibLoadedView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/18/15.
//  Copyright © 2016 Appsaurus. All rights reserved.
//

import Layman
import Swiftest

/**
 Example Usage for class named "YourSubclassView":
 1. Create subclass of NibLoadedView named YourSubclassView
 2. Create nib file named YourSubclassView.xib.
 3. Set xib file's owner in inspection panel to YourSubclassView
 4. Embed view in storyboard, change class to YourSubclassView. Or just instantiate programatically.
 */
@IBDesignable open class NibLoadedView: BaseView {
    var view: UIView!
    open var nibName: String {
        return self.className
    }

    override open func initProperties() {
        super.initProperties()
        self.view = self.loadNib()
        self.view.backgroundColor = UIColor.clear
        self.view.frame = bounds
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.view)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.view.pinToSuperview()
    }

    open func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        // swiftlint:disable force_cast
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
