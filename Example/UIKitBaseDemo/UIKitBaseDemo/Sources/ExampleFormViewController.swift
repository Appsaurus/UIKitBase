//
//  ExampleFormViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitBase
import Swiftest
import Algorithm
import SwiftDate
import Layman


open class ExampleFormViewController: FormTableViewController<Any?, Any?>{
    let firstNameField = NameTextField(fieldName: "First")
    let lastNameField = NameTextField(fieldName: "Last")
//    let locationField = FormLocationField<MaterialTextField>(fieldName: "Location")
	let dateField = DatePickerFormField<MaterialTextField>(fieldName: "Birthdate").then { (field) in
		field.maxDate = Date() - 21.years
	}
    let disabledField = FormTextField<MaterialTextField, String>(fieldName: "Disabled Title")
    let readOnlyField = FormTextField<MaterialTextField, String>(fieldName: "Read Only Title")
    //    let birthdayField = BirthdayPickerField(fieldName: "Birthday")
    
    open override var headerPromptText: String?{
        return "Please give us your blood type and social security number."
    }
    
    open override func createForm() -> Form {
		disabledField.isEnabled = false
		readOnlyField.contentView.isReadOnly = true
		readOnlyField.value = "Read only value"
        return Form(fields: [firstNameField,
                             lastNameField,
                             dateField,
//                             locationField,
                             disabledField,
                             readOnlyField
                             ])
    }
    
    open override var fieldCellInsets: LayoutPadding {
        return LayoutPadding(horizontal: 20.0, vertical: 5.0)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.automaticallySizeCellHeights(40)
        submitButton.titleMap = [.normal : "Submit",
                                 .activity: "Acivity"]
        
    }

	open override func style() {
		super.style()
		tableView.separatorColor = .clear
	}

	open override func createSubviews() {
		super.createSubviews()

		let viewModel = LegalDisclosureViewModel(legalDocuments: SortedDictionary(elements: ("Terms of Use", "https://www.google.com"),
																				  			("Privacy Policy", "https://www.google.com")))
		let legalDisclosure = LegalDisclosureView(viewModel: viewModel)

		legalDisclosure.frame = CGRect(x: 0.0, y: 0, width: tableView.frame.size.width, height: 75.0)
		tableView.tableFooterView = legalDisclosure
	}

    open override func submit(_ submission: Any?, _ resultClosure: @escaping (Result<Any?, Error>) -> Void) {
        resultClosure(.success(nil))
//        MockableNetwork.makeFakeNetworkCall(delay: 1,
//                                        chanceOfSuccess: 75,
//                                        success: success,
//                                        failure: {failure(BasicError.unknown)})
    }
}


class NameTextField: FormTextField<MaterialTextField, String>{
    
    open override func initProperties() {
        super.initProperties()
        minCharacterCountLimit = 4
    }
    
    override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
//        contentView.styleMap = .materialStyleMap(color: .primaryContrast)
    }
    
}
