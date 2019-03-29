//
//  LegalDisclosureViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/30/18.
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman
import Algorithm

open class LegalAcknowledgementAlertViewController: StackedAlertViewController{

	public let acceptButton: BaseButton = BaseButton(titles: [.any : "I Accept"])
	public var onAccept: VoidClosure
	public var onDeny: VoidClosure?
	public let legalDisclosureView: LegalDisclosureView

	public required init(legalDisclosureViewModel: LegalDisclosureViewModel,
						 alertViewModel: AlertViewModel = AlertViewModel(alertTitle: "Accept Terms", dismissButtonTitle: "Cancel"),
						 onAccept: @escaping VoidClosure,
						 onDeny: VoidClosure? = nil){
		self.onAccept = onAccept
		self.onDeny = onDeny
		self.legalDisclosureView = LegalDisclosureView(viewModel: legalDisclosureViewModel)
		super.init(viewModel: alertViewModel)
	}

	open override func userDidDismiss() {
		super.userDidDismiss()
		onDeny?()
	}

	open override func setupControlActions() {
		super.setupControlActions()
		acceptButton.onTap = { [weak self] in
			guard let `self` = self else { return }
			self.dismiss(animated: true, completion: self.onAccept)
		}
	}
	open override func style(){
		super.style()
		acceptButton.styleMap = [.any : .solid(backgroundColor: .primary,
											   textColor: .primaryContrast,
											   font: .bold(.button))]
	}
	required public init(viewModel: AlertViewModel) {
		fatalError("init(viewModel:) has not been implemented")
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open override func createSubviews() {
		super.createSubviews()
		stackView.insertArrangedSubview(legalDisclosureView, at: 1)
	}
	open override func createAutoLayoutConstraints() {
		super.createAutoLayoutConstraints()
		acceptButton.height.equal(to: 70.0)
	}

	open override var bottomStackArrangedSubviews: [UIView]{
		return [acceptButton] + super.bottomStackArrangedSubviews
	}



}
