//
//  LegalDisclosureViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/30/18.
//

import Algorithm
import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

open class LegalAcknowledgementAlertViewController: StackedAlertViewController {
    public let acceptButton = BaseButton(titles: [.any: "I Accept"])
    public var onAccept: VoidClosure
    public var onDeny: VoidClosure?
    public let legalDisclosureView: LegalDisclosureView

    public required init(legalDisclosureViewModel: LegalDisclosureViewModel,
                         alertViewModel: AlertViewModel = AlertViewModel(alertTitle: "Accept Terms", dismissButtonTitle: "Cancel"),
                         onAccept: @escaping VoidClosure,
                         onDeny: VoidClosure? = nil)
    {
        self.onAccept = onAccept
        self.onDeny = onDeny
        self.legalDisclosureView = LegalDisclosureView(viewModel: legalDisclosureViewModel)
        super.init(viewModel: alertViewModel)
    }

    override open func userDidDismiss() {
        super.userDidDismiss()
        self.onDeny?()
    }

    override open func setupControlActions() {
        super.setupControlActions()
        self.acceptButton.onTap = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: self.onAccept)
        }
    }

    override open func style() {
        super.style()
        self.acceptButton.styleMap = [.any: .solid(backgroundColor: .primary,
                                                   textColor: .primaryContrast,
                                                   font: .bold(.button))]
    }

    public required init(viewModel: AlertViewModel) {
        fatalError("init(viewModel:) has not been implemented")
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func createSubviews() {
        super.createSubviews()
        stackView.insertArrangedSubview(self.legalDisclosureView, at: 1)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.acceptButton.height.equal(to: 70.0)
    }

    override open var bottomStackArrangedSubviews: [UIView] {
        return [self.acceptButton] + super.bottomStackArrangedSubviews
    }
}
