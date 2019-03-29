//
//  FormLabelField.swift
//  Pods
//
//  Created by Brian Strobach on 9/8/17.
//
//

import Swiftest
import UIKitTheme

open class FormLabelField<ContentView: UIView, Value: Any>: FormField<ContentView, Value> where ContentView: FormFieldViewProtocol {
    open lazy var valueLabel: UILabel = {
        self.labelToManage()
    }()

    open func labelToManage() -> UILabel {
        guard let label = self.contentView as? UILabel ?? self.subviews(ofType: UILabel.self).first else {
            assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
            return UILabel()
        }

        return label
    }

    open override func updateContentView() {
        super.updateContentView()
        guard let value = self.value, let description = self.textDescription(for: value) else {
            valueLabel.text = nil
            let textFieldPlaceholderStyle = TextStyle(color: UIColor(r: 199, g: 199, b: 205), font: valueLabel.font)
            let placeholderText = placeholder ?? fieldName
            valueLabel.attributedText = placeholderText.apply(style: textFieldPlaceholderStyle.attributed)
            return
        }
        debugLog("Updating value for field: \(fieldName) to \(description)")
        valueLabel.attributedText = nil
        valueLabel.text = description
    }
}
