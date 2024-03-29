/// /
/// /  FormTableViewController.swift
/// /  Pods
/// /
/// /  Created by Brian Strobach on 8/8/17.
/// /
/// /
import Swiftest
import UIKitBase
import Layman

public enum FormFieldBehavior {
    case indicatesOptionalFields
    case indicatesRequiredFields
}

// Basis for any form viewcontroller. Doesn't implement any view logic for fields.
open class BaseFormViewController<Submission: Equatable, Response>: BaseContainerViewController, FormDelegate, SubmissionManaged {
    public var onCompletion: ResultClosure<Response>?

    open lazy var formToolbar: FormToolbar? = self.createFormToolbar()

    open var submitButtonPosition: ManagedButtonPosition = .navBarTrailing
    open var autoSubmitsValidForm = false
    open var autoPrefillsForm = true
    open var autoAssignFirstResponder = false
    open var showsValidationErrorsOnDisbledSubmit = true
    open var popsOrDismissesOnSuccess: Bool = false
    open var cachedSubmissionState: Submission?
    open var formFieldBehaviors: Set<FormFieldBehavior> = [] {
        didSet {
            self.updateFieldBehaviors()
        }
    }

    open lazy var form: Form = self.createForm()
    open lazy var textFieldStyleMap: TextFieldStyleMap = .materialStyleMap(contrasting: self.view.backgroundColor ?? App.style.formViewControllerBackgroundColor)
    override open func style() {
        super.style()
        self.formToolbar?.toolBarStyle = FormToolbarStyle()
        view.backgroundColor = App.style.formViewControllerBackgroundColor
        self.style(fields: self.form.fields)
    }

    open func style(fields: [FormFieldProtocol]) {
        for field in fields {
            guard let textField = field.getContentView() as? StatefulTextField else {
                continue
            }
            textField.styleMap = self.textFieldStyleMap
        }
    }

    open func prefillForm() {}

    public func cacheSubmission() {
        self.cachedSubmissionState = try? self.createSubmission()
    }

    public init(onCompletion: ResultClosure<Response>? = nil) {
        self.onCompletion = onCompletion
        super.init(callInitLifecycle: true)
    }

    override public init(callInitLifecycle: Bool) {
        super.init(callInitLifecycle: callInitLifecycle)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.form.formDelegate = self
        if self.autoPrefillsForm {
            self.prefillForm()
        }
        if noEditsBehavior != nil {
            self.cacheSubmission()
        }
        self.form.validate(displayErrors: false)
        self.updateSubmitButtonState()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.autoAssignFirstResponder {
            self.assignFirstResponderToNextInvalidField()
        }
    }

    override open func createSubviews() {
        super.createSubviews()
        setupSubmitButton(configuration: ManagedButtonConfiguration(position: self.submitButtonPosition))
    }

    open func createForm() -> Form {
        let fields = self.createFields()
        for field in fields {
            field.behaviors = self.formFieldBehaviors
        }
        return Form(fields: fields)
    }

    open func createFields() -> [FormFieldProtocol] {
        assertionFailure("Must be created by subclass")
        return []
    }

    open func createFormToolbar() -> FormToolbar? {
        var textFields: [FormInput] = []
        for field in self.form.fields where field is FormInput {
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
        self.updateSubmitButtonState()
    }

    open func formPassedValidation(_ form: Form) {
        self.updateSubmitButtonState()
        autoSubmitIfAllowed()
    }

    open func formFailedValidation(_ form: Form, failures: [ValidationFailure]) {
        self.updateSubmitButtonState()
    }

    open func fieldPassedValidation(_ field: FormFieldProtocol) {}

    open func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {}

    open func fieldIsValidating(_ field: FormFieldProtocol) {}

    open func fieldDidBeginEditing(_ field: FormFieldProtocol) {
        self.formToolbar?.update()
    }

    open func fieldDidEndEditing(_ field: FormFieldProtocol) {}

    func textFieldDidBeginEditing(_ textField: UITextField) {}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.formToolbar?.goForward()
        return true
    }

    // MARK: SubmitButtonManaged

    open func didPressSubmitButtonWhileDisabled() {
        if self.showsValidationErrorsOnDisbledSubmit {
            self.displayFormErrors()
        }
    }

    open func updateSubmitButtonState() {
        switch self.form.status {
        case .testingInProgress:
            submitButton.state = .activity
        default:
            submitButton.state = self.userCanSubmit() ? .normal : .disabled
        }
    }

    open func userCanSubmit() -> Bool {
        let formIsValid = self.form.status == .valid
        guard noEditsBehavior == .disableSubmit else {
            return formIsValid
        }
        return self.submissionHasBeenEdited() && formIsValid
    }

    open func displayFormErrors(withAlert: Bool = false) {
        for field in self.form.fields {
            field.validate(displayErrors: true)
        }
        if withAlert {
            self.form.presentFormErrorsAlertView(self)
        } else {
            self.assignFirstResponderToNextInvalidField()
        }
    }

    open func submit(_ submission: Submission, _ resultClosure: @escaping (Result<Response, Error>) -> Void) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open func createSubmission() throws -> Submission {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return try self.createSubmission()
    }

    open func submissionDidSucceed(with response: Response) {
        guard self.popsOrDismissesOnSuccess else { return }
        popOrDismiss()
    }

    open func submissionDidFail(with error: Error) {
        switch error {
        case SubmissionError.submittedNoEdits:
            // No need to report back to user, just dismiss
            break
        default:
            showError(error: error)
        }
    }

    open func submissionHasBeenEdited() -> Bool {
        guard let cachedSubmissionState = cachedSubmissionState,
              let submission = try? createSubmission()
        else {
            return true
        }
        return cachedSubmissionState != submission
    }

    open func updateFieldBehaviors() {
        for field in self.form.fields {
            field.behaviors = self.formFieldBehaviors
        }
    }
}

extension FormTableViewController: UITableViewReferencing {
    public var managedTableView: UITableView {
        return tableView
    }
}

open class FormTableViewController<Submission: Equatable, Response>: BaseFormViewController<Submission, Response>, UITableViewControllerProtocol {
//    public typealias SVH = ScrollViewHeader
    private var keyboardAvoiding: KeyboardAvoiding!

//    open override func createMixins() -> [LifeCycle] {
//        return super.createMixins() + DynamicHeightTableViewAccessoriesMixins(self)
//    }

    open var tableView = UITableView().then { tv in
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

    override open func style() {
        super.style()
        self.tableView.backgroundColor = containerView.backgroundColor
        let backgroundContrast = view.backgroundColor?.contrastingColor(fromCandidates: [.primary, .primaryContrast]) ?? .primary
        self.headerPromptLabel?.apply(textStyle: .displayHeadline(color: backgroundContrast))
    }

    override open func initProperties() {
        super.initProperties()
        containedView = self.tableView
        self.tableView.separatorStyle = .none
//        containedViewAvoidsKeyboard = true
    }

    override open func setupDelegates() {
        super.setupDelegates()
        self.tableView.setController(self)
    }

    override open func createSubviews() {
        super.createSubviews()
        guard let label = headerPromptLabel else { return }
        self.tableView.setupDynamicHeader(label)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.automaticallySizeCellHeights(200)
        self.tableView.reloadData()

        self.keyboardAvoiding = KeyboardAvoiding()
            .onKeyboardWillShow { [weak self] rect in
                guard let self = self else { return }
                self.tableView.contentInset.bottom = rect.height
            }
            .onKeyboardDidShow { _ in
            }
            .onKeyboardWillHide { [weak self] in
                guard let self = self else { return }
                self.tableView.contentInset.bottom = 0
            }
            .onKeyboardDidHide {}
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardAvoiding.start()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.keyboardAvoiding.stop()
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = form.fields[indexPath.row]
        let cell = FormFieldCell(field: field as! UIView, insets: self.fieldCellInsets)
        self.customize(fieldCell: cell, at: indexPath)
        return cell
    }

    open func customize(fieldCell: FormFieldCell, at indexPath: IndexPath) {
        if fieldCell.field is FormPickerFieldProtocol {
            fieldCell.accessoryType = .disclosureIndicator
        }
    }
}

open class KeyboardAvoiding {
    open var willShow: ((CGRect) -> Void)?
    open var didShow: ((CGRect) -> Void)?
    open var willHide: (() -> Void)?
    open var didHide: (() -> Void)?

    public init(willShow: ((CGRect) -> Void)? = nil,
                didShow: ((CGRect) -> Void)? = nil,
                willHide: (() -> Void)? = nil,
                didHide: (() -> Void)? = nil)
    {
        self.willShow = willShow
        self.didShow = didShow
        self.willHide = willHide
        self.didHide = didHide
    }

    public func onKeyboardWillShow(_ willShow: @escaping ((CGRect) -> Void)) -> KeyboardAvoiding {
        self.willShow = willShow
        return self
    }

    public func onKeyboardDidShow(_ didShow: @escaping ((CGRect) -> Void)) -> KeyboardAvoiding {
        self.didShow = didShow
        return self
    }

    public func onKeyboardWillHide(_ willHide: @escaping (() -> Void)) -> KeyboardAvoiding {
        self.willHide = willHide
        return self
    }

    public func onKeyboardDidHide(_ didHide: @escaping (() -> Void)) -> KeyboardAvoiding {
        self.didHide = didHide
        return self
    }

    public func start() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }

    public func stop() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    private func animate(curve: Int, duration: Double, _ block: @escaping (() -> Void)) {
        let animationCurve = UIView.AnimationCurve(rawValue: curve) ?? .linear
        let animationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))

        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: block, completion: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        self.animate(curve: curve, duration: duration) {
            self.willShow?(frame)
        }
    }

    @objc func keyboardDidShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        self.animate(curve: curve, duration: duration) {
            self.didShow?(frame)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        else {
            return
        }
        self.animate(curve: curve, duration: duration) {
            self.willHide?()
        }
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        else {
            return
        }

        self.animate(curve: curve, duration: duration) {
            self.didHide?()
        }
    }
}
