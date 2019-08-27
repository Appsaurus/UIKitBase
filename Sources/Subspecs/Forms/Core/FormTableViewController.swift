import Layman
////
////  FormTableViewController.swift
////  Pods
////
////  Created by Brian Strobach on 8/8/17.
////
////
import Swiftest
import UIKitMixinable
import UIKitTheme
// Basis for any form viewcontroller. Doesn't implement any view logic for fields.
open class BaseFormViewController<Submission, Response>: BaseContainerViewController, FormDelegate, SubmissionManaged {
    public var onCompletion: ResultClosure<Response>?

    open lazy var formToolbar: FormToolbar? = {
        self.createFormToolbar()
    }()

    open var submitButtonPosition: ManagedButtonPosition = .navBarTrailing
    open var autoSubmitsValidForm: Bool = false
    open var autoPrefillsForm: Bool = true
    open var autoAssignFirstResponder: Bool = false
    open lazy var form: Form = self.createForm()
    open lazy var textFieldStyleMap: TextFieldStyleMap = .materialStyleMap(contrasting: self.view.backgroundColor ?? App.style.formViewControllerBackgroundColor)
    open override func style() {
        super.style()
        formToolbar?.toolBarStyle = FormToolbarStyle()
        view.backgroundColor = App.style.formViewControllerBackgroundColor
        style(fields: form.fields)
    }

    open func style(fields: [FormFieldProtocol]) {
        for field in fields {
            guard let textField = field.getContentView() as? StatefulTextField else {
                continue
            }
            textField.styleMap = textFieldStyleMap
        }
    }

    open func prefillForm(){

    }

    public init(onCompletion: ResultClosure<Response>? = nil) {
        self.onCompletion = onCompletion
        super.init(callDidInit: true)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        form.formDelegate = self
        form.validate(displayErrors: false)
        updateSubmitButtonState()
        if autoPrefillsForm {
            prefillForm()
        }
    }


    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if autoAssignFirstResponder {
            assignFirstResponderToNextInvalidField()
        }
    }
    open override func createSubviews() {
        super.createSubviews()
        setupSubmitButton(configuration: ManagedButtonConfiguration(position: submitButtonPosition))
    }

    open func createForm() -> Form {
        return Form(fields: createFields())
    }

    open func createFields() -> [FormFieldProtocol] {
        assertionFailure("Must be created by subclass")
        return []
    }

    open func createFormToolbar() -> FormToolbar? {
        var textFields: [FormInput] = []
        for field in form.fields where field is FormInput {
            // swiftlint:disable force_cast
            textFields.append(field as! FormInput)
        }
        let toolbar = FormToolbar(inputs: textFields)
        toolbar.direction = .upDown
        return toolbar
    }

    open func assignFirstResponderToNextInvalidField() {
        if let field = form.fields.first(where: { $0.validationStatus != .valid && $0.responder() != nil })?.responder() {
            field.becomeFirstResponder()
        }
    }

    open func formIsValidating(_ form: Form) {
        updateSubmitButtonState()
    }

    open func formPassedValidation(_ form: Form) {
        updateSubmitButtonState()
        autoSubmitIfAllowed()
    }

    open func formFailedValidation(_ form: Form, failures: [ValidationFailure]) {
        updateSubmitButtonState()
    }

    open func fieldPassedValidation(_ field: FormFieldProtocol) {}

    open func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {}

    open func fieldIsValidating(_ field: FormFieldProtocol) {}

    open func fieldDidBeginEditing(_ field: FormFieldProtocol) {
        formToolbar?.update()
    }

    open func fieldDidEndEditing(_ field: FormFieldProtocol) {}

    func textFieldDidBeginEditing(_ textField: UITextField) {}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        formToolbar?.goForward()
        return true
    }

    // MARK: SubmitButtonManaged

    open func didPressSubmitButtonWhileDisabled() {}

    open func updateSubmitButtonState() {
        switch form.status {
        case .testingInProgress:
            submitButton.state = .activity
        default:
            submitButton.state = userCanSubmit() ? .normal : .disabled
        }
    }

    open func userCanSubmit() -> Bool {
        return form.status == .valid
    }

    @objc open func displayFormErrors(_ sender: UIBarButtonItem) {
        _ = [String]()
        for field in form.fields {
            field.validate(displayErrors: true)
        }
        form.presentFormErrorsAlertView(self)
    }

    open func submit(_ submission: Submission, _ resultClosure: @escaping (Result<Response, Error>) -> Void) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open func createSubmission() throws -> Submission {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return try createSubmission()
    }

    open func submissionDidSucceed(with response: Response) {}

    open func submissionDidFail(with error: Error) {
        showError(error: error)
    }
}

extension FormTableViewController: UITableViewReferencing {
    public var managedTableView: UITableView {
        return tableView
    }
}

open class FormTableViewController<Submission, Response>: BaseFormViewController<Submission, Response>, UITableViewControllerProtocol {
//    public typealias SVH = ScrollViewHeader

    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + DynamicHeightTableViewAccessoriesMixins(self)
    }

    open var tableView: UITableView = UITableView().then { tv in
        tv.backgroundColor = .clear
    }

    open var headerPromptText: String? {
        return nil
    }

    open lazy var headerPromptLabel: UILabel? = {
        guard let promptText = self.headerPromptText else { return nil }
        let headerLabel = UILabel()
        headerLabel.wrapWords()
        headerLabel.text = promptText
        return headerLabel
    }()

    open var fieldCellInsets: LayoutPadding {
        return LayoutPadding(horizontal: 20.0, vertical: 5.0)
    }

    open override func style() {
        super.style()
        tableView.backgroundColor = containerView.backgroundColor
        let backgroundContrast = view.backgroundColor?.contrastingColor(fromCandidates: [.primary, .primaryContrast]) ?? .primary
        headerPromptLabel?.apply(textStyle: .displayHeadline(color: backgroundContrast))
    }

    open override func initProperties() {
        super.initProperties()
        containedView = tableView
    }

    open override func setupDelegates() {
        super.setupDelegates()
        tableView.setController(self)
    }

    open override func createSubviews() {
        super.createSubviews()
        guard let label = headerPromptLabel else { return }
        tableView.setupDynamicHeader(label)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.automaticallySizeCellHeights(200)
        tableView.reloadData()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.dynamicallySizeHeight(of: .header, .footer)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.dynamicallySizeHeight(of: .header, .footer)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = form.fields[indexPath.row]
        let cell = FormFieldCell(field: field as! UIView, insets: fieldCellInsets)
        customize(fieldCell: cell, at: indexPath)
        return cell
    }

    open func customize(fieldCell: FormFieldCell, at indexPath: IndexPath) {
        if fieldCell.field is FormPickerFieldProtocol {
            fieldCell.accessoryType = .disclosureIndicator
        }
    }
}
