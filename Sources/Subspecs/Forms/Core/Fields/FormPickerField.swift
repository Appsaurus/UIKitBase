//
//  FormPickerField.swift
//  Pods
//
//  Created by Brian Strobach on 9/8/17.
//
//

import Foundation
import UIKit

public protocol FormPickerFieldProtocol {}
open class FormPickerField<ContentView: UIView, Value: Any, VC: UIViewController>: FormField<ContentView, Value>, FormPickerFieldProtocol
    where VC: TaskResultDelegate, VC.TaskResult == Value, ContentView: FormFieldViewProtocol {
    open lazy var pickerViewController: VC = VC(nibName: nil, bundle: nil)

    override open var canBecomeFirstResponder: Bool {
        return false
    }

//    open override func becomeFirstResponder() -> Bool {
//        self.presentPickerViewController()
//        return true
//    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
    }

    override open func fieldWasTapped() {
        self.presentPickerViewController()
    }

    open func presentPickerViewController() {
        self.configurePickerTaskHandler(picker: self.pickerViewController)
        parentViewController?.view.endEditing(true)
        parentViewController?.navigationController?.push(self.pickerViewController)
    }

    open func configurePickerTaskHandler(picker: VC) {
        picker.onDidFinishTask = (result: { [weak self] value in
            guard let self = self else { return }

            self.value = value
            self.parentViewController?.navigationController?.popViewController(animated: true)
        }, cancelled: { [weak self] in
            self?.parentViewController?.navigationController?.popViewController(animated: true)
        })
    }
}
