//
//  FormLabelField.swift
//  Pods
//
//  Created by Brian Strobach on 9/8/17.
//
//

import Swiftest
import UIKitBase

open class FormLabelField<ContentView: UIView, Value: Any>: FormField<ContentView, Value> where ContentView: FormFieldViewProtocol {
    open lazy var valueLabel: UILabel = self.labelToManage()

    open func labelToManage() -> UILabel {
        guard let label = contentView as? UILabel ?? subviews(ofType: UILabel.self).first else {
            assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
            return UILabel()
        }

        return label
    }

    override open func updateContentView() {
        super.updateContentView()
        guard let value = self.value, let description = textDescription(for: value) else {
            self.valueLabel.text = nil
            let textFieldPlaceholderStyle = TextStyle(color: UIColor(r: 199, g: 199, b: 205), font: valueLabel.font)
            let placeholderText = placeholder ?? fieldName
            self.valueLabel.attributedText = placeholderText.apply(style: textFieldPlaceholderStyle.attributed)
            return
        }
        debugLog("Updating value for field: \(fieldName) to \(description)")
        self.valueLabel.attributedText = nil
        self.valueLabel.text = description
    }
}
