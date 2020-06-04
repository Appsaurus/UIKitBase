//
//  BaseStackViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/19/17.
//

import Foundation
import Layman
import Nuke
import Swiftest
import UIKitExtensions
open class BaseStackViewController: BaseViewController {
    open lazy var stackView: UIStackView = UIStackView(stackViewConfiguration: defaultStackViewConfiguration, arrangedSubviews: initialArrangedSubviews())
    open var stackViewBackgroundView: UIView = UIView()
    open lazy var defaultStackViewConfiguration: StackViewConfiguration = StackViewConfiguration.equalSpacingVertical(alignment: .fill, spacing: 12)
    open lazy var stackviewLayoutMargins: UIEdgeInsets = 25
    open lazy var verticalLayoutPadding: CGFloat = 25.0
    open lazy var horizontalLayoutPadding: CGFloat = 25.0
    open func initialArrangedSubviews() -> [UIView] {
        return []
    }

    override open func createSubviews() {
        super.createSubviews()
        self.stackView.addSubview(self.stackViewBackgroundView)
        self.stackView.sendSubviewToBack(self.stackViewBackgroundView)
        view.addSubview(self.stackView)
        self.stackView.layoutMargins = self.stackviewLayoutMargins
        self.stackView.isLayoutMarginsRelativeArrangement = true
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

//        let stackViewIntroAnimation: [MotionModifier] = [.translate(y: -UIScreen.screenHeight/2.0 + stackView.h),
//                                                         .duration(0.3)
//        ]
//        stackView.transition(stackViewIntroAnimation)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.stackView.centerInSuperview()
        self.stackView.edgeAnchors.insetOrEqual(to: edgeAnchors.inset(self.horizontalLayoutPadding, self.verticalLayoutPadding))
        self.stackView.hugContent()
        self.stackViewBackgroundView.pinToSuperview()
        self.initialArrangedSubviews().forEach { view in
            view.resistCompression()
            view.heightAnchor.greaterThanOrEqual(to: 0)
        }
    }
}

open class AlertViewModel {
    public var headerImage: UIImage?
    public var headerImageUrl: URLConvertible?
    public var alertTitle: String?
    public var message: String?
    public var dismissButtonTitle: String

    public init(headerImage: UIImage? = nil,
                headerImageUrl: URLConvertible? = nil,
                alertTitle: String? = nil,
                message: String? = nil,
                dismissButtonTitle: String = "Dismiss") {
        self.headerImage = headerImage
        self.headerImageUrl = headerImageUrl
        self.alertTitle = alertTitle
        self.message = message
        self.dismissButtonTitle = dismissButtonTitle
    }
}

open class StackedAlertViewController: BaseStackViewController {
    open var viewModel: AlertViewModel = AlertViewModel()

    open lazy var headerImageView: UIImageView = UIImageView()
    open lazy var alertTitleLabel: UILabel = UILabel()
    open lazy var messageLabel: UILabel = UILabel()
    open lazy var dismissButton = BaseButton()
    open lazy var bottomStackView: UIStackView = UIStackView(stackViewConfiguration: defaultBottomStackViewConfiguration, arrangedSubviews: initialBottomArrangedSubviews())
    open lazy var defaultBottomStackViewConfiguration: StackViewConfiguration = StackViewConfiguration.equalSpacingVertical(alignment: .center, spacing: 8.0)
    open var showsDismissButton: Bool = { true }()

    override open func initialArrangedSubviews() -> [UIView] {
        return self.optionalArrangedSubviews + [self.bottomStackView]
    }

    open func initialBottomArrangedSubviews() -> [UIView] {
        return self.bottomStackArrangedSubviews
    }

    public required init(viewModel: AlertViewModel = AlertViewModel()) {
        super.init(callInitLifecycle: false)
        self.viewModel = viewModel
        initLifecycle(.programmatically)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.bottomStackView.hugContent()
        self.initialBottomArrangedSubviews().forEach { view in
            view.resistCompression()
            view.size.greaterThanOrEqual(to: 0)
            view.width.equal(to: view.assertSuperview.width)
        }
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        self.display(viewModel: self.viewModel)
    }

    open var optionalArrangedSubviews: [UIView] {
        var optionalViews: [UIView] = []
        if viewModel.headerImage != nil || viewModel.headerImageUrl != nil {
            headerImageView.contentMode = .scaleAspectFit
            optionalViews.append(headerImageView)
        }
        if viewModel.alertTitle.hasNonEmptyValue {
            alertTitleLabel.wrapWords()
            alertTitleLabel.textAlignment = .center
            optionalViews.append(alertTitleLabel)
        }
        if viewModel.message.hasNonEmptyValue {
            messageLabel.wrapWords()
            messageLabel.textAlignment = .center
            optionalViews.append(messageLabel)
        }

        return optionalViews
    }

    open var bottomStackArrangedSubviews: [UIView] {
        guard showsDismissButton else {
            return []
        }
        dismissButton.titleMap = [.any: viewModel.dismissButtonTitle]
        return [dismissButton]
    }

    open func display(viewModel: AlertViewModel) {
        if let image = viewModel.headerImage {
            self.headerImageView.image = image
        } else if let imageURL = viewModel.headerImageUrl?.toURL {
            self.headerImageView.loadImage(with: imageURL)
        }
        self.alertTitleLabel.text =? viewModel.alertTitle
        self.messageLabel.text =? viewModel.message
    }

    override open func style() {
        super.style()
        stackViewBackgroundView.backgroundColor = .viewControllerBaseViewBackgroundColor
        if self.viewModel.alertTitle.hasNonEmptyValue {
            self.alertTitleLabel.apply(textStyle: .semibold(color: .primary, size: .button + 2))
        }
        if self.viewModel.message.hasNonEmptyValue {
            self.messageLabel.apply(textStyle: .regular(size: UIFont.labelFontSize))
        }

        self.dismissButton.apply(textStyle: .ultraLight(color: UIColor.textMediumDark.withAlphaComponent(0.8), size: .button - 2.0))
    }

    override open func setupControlActions() {
        super.setupControlActions()
        self.dismissButton.onTap = self.userDidTapDismissButton
    }

    // MARK: Control Actions

    open func userDidTapDismissButton() {
        dismiss(animated: true) { [weak self] in
            self?.userDidDismiss()
        }
    }

    open func userDidDismiss() {}

    open func present(from presenter: UIViewController) {
        view.setBackgroundBlur(style: .dark)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        presenter.present(viewController: self)
    }
}
