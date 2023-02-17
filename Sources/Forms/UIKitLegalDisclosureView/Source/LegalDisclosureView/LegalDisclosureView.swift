//
//  LegalDisclosureView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/29/18.
//

import Layman
import Swiftest
import UIKitBase
import ActiveLabel
import Algorithm

// open class LegalDisclosureManager{
//	func presentAlert(viewModel: LegalDisclosureViewModel, onCancel: VoidClosure? = nil, onAcceptance: VoidClosure){
//
//	}
//	func inlineLegalDisclosureView(viewModel: LegalDisclosureViewModel, onCancel: VoidClosure? = nil, onAcceptance: VoidClosure){
//
//	}
// }

// public enum LegalDisclosureUserAcknowledgement{
//	case check, none
// }

public struct LegalDisclosureViewModel {
    public var message: String
    public var legalDocuments: SortedDictionary<String, String>
    public var conjunction: String
    public var includeOxfordComma: Bool
    /// Example usage:
    /// 		let termsOfUse = "Terms of Use"
    /// 		let privacyPolicy = "Privacy Policy"
    /// 		let message = "By signing up, you agree to our \(termsOfUse) and \(privacyPolicy)."
    /// 		let viewModel = LegalDisclosureViewModel(legalDocuments: [termsOfUse : "www.google.com",
    /// 															  privacyPolicy : "www.google.com"])
    /// 		let legalDisclosure = LegalDisclosureView(viewModel: viewModel)
    ///
    /// - Parameters:
    ///   - message: The label's text, if it does not contain key names for links they will be generated.
    ///   - legalDocuments: String URLS keyed by name of document as it appears in the message text.
    public init(message: String = "By signing up, you agree to our",
                legalDocuments: SortedDictionary<String, String>,
                conjunction: String = "and",
                includeOxfordComma: Bool = true)
    {
        self.message = message
        self.legalDocuments = legalDocuments
        self.conjunction = conjunction
        self.includeOxfordComma = includeOxfordComma
        let containsKey: Bool = legalDocuments.keys.contains(where: { message.contains($0) })
        guard !containsKey else {
            return
        }

        self.message = self.generateMessageText()
    }

    public var regularExpressionPattern: String {
        let keys: [String] = Array(legalDocuments.keys)
        var verEx = VerEx()
        for (index, key) in keys.enumerated() {
            switch index {
            case 0:
                verEx = verEx.find(key)
            default:
                verEx = verEx.or(key)
            }
        }
        return verEx.pattern
    }

    public func generateMessageText() -> String {
        let list = StringUtils.English.punctuatedList(from: self.legalDocuments.keys, conjunction: self.conjunction, includeOxfordComma: self.includeOxfordComma)
        return "\(self.message) \(list)."
    }
}

open class LegalDisclosureView: BaseView {
    open var label = ActiveLabel()
    open var viewModel: LegalDisclosureViewModel
    open var onPresented: VoidClosure?
    
    var customType: ActiveType {
        ActiveType.custom(pattern: self.viewModel.regularExpressionPattern)
    }
    public required init(viewModel: LegalDisclosureViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }

    
    open override func style() {
        super.style()
        styleLabel()
    }
    
    func styleLabel() {
        self.label.enabledTypes = [customType]
        self.label.apply(textStyle: .light(color: .deselected, size: .button))
        self.label.customColor[customType] = .selected
        self.label.customSelectedColor[customType] = .selected
    }
    
    override open func initProperties() {
        super.initProperties()

        self.styleLabel()
        self.label.handleCustomTap(for: customType) { [weak self] element in
            guard let self = self else { return }
            let pagingVC = PagingWebViewController(titledUrlStrings: self.viewModel.legalDocuments)
            pagingVC.initialPageIndex = self.viewModel.legalDocuments.keys.firstIndex(of: element) ?? 0

            guard let parent = self.parentViewController else { return }
            self.onPresented?()
            if let nav = parent.navigationController {
                nav.pushViewController(pagingVC, animated: true)
            } else {
                let dismissableNav = DismissableNavigationController(dismissableViewController: pagingVC)
                parent.present(viewController: dismissableNav)
            }
        }
        self.label.text = self.viewModel.message
        self.label.textAlignment = .center
        self.label.wrapWords()
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.label)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.label.edges.equal(to: .inset(10, 20))
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

