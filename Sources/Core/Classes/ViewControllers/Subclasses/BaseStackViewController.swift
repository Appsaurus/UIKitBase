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

    open override func createSubviews() {
        super.createSubviews()
        stackView.addSubview(stackViewBackgroundView)
        stackView.sendSubviewToBack(stackViewBackgroundView)
        view.addSubview(stackView)
        stackView.layoutMargins = stackviewLayoutMargins
        stackView.isLayoutMarginsRelativeArrangement = true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

//        let stackViewIntroAnimation: [MotionModifier] = [.translate(y: -UIScreen.screenHeight/2.0 + stackView.h),
//                                                         .duration(0.3)
//        ]
//        stackView.transition(stackViewIntroAnimation)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        stackView.centerInSuperview()
        stackView.edgeAnchors.insetOrEqual(to: edgeAnchors.inset(horizontalLayoutPadding, verticalLayoutPadding))
        stackView.hugContent()
        stackViewBackgroundView.pinToSuperview()
        initialArrangedSubviews().forEach { view in
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

    open override func initialArrangedSubviews() -> [UIView] {
        return optionalArrangedSubviews + [bottomStackView]
    }

    open func initialBottomArrangedSubviews() -> [UIView] {
        return bottomStackArrangedSubviews
    }

    public required init(viewModel: AlertViewModel = AlertViewModel()) {
        super.init(callInitLifecycle: false)
        self.viewModel = viewModel
        initLifecycle(.programmatically)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        bottomStackView.hugContent()
        initialBottomArrangedSubviews().forEach { view in
            view.resistCompression()
            view.size.greaterThanOrEqual(to: 0)
            view.width.equal(to: view.assertSuperview.width)
        }
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        display(viewModel: viewModel)
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
            headerImageView.image = image
        } else if let imageURL = viewModel.headerImageUrl?.toURL {
            headerImageView.loadImage(with: imageURL)
        }
        alertTitleLabel.text =? viewModel.alertTitle
        messageLabel.text =? viewModel.message
    }

    open override func style() {
        super.style()
        stackViewBackgroundView.backgroundColor = .viewControllerBaseViewBackgroundColor
        if viewModel.alertTitle.hasNonEmptyValue {
            alertTitleLabel.apply(textStyle: .semibold(color: .primary, size: .button + 2))
        }
        if viewModel.message.hasNonEmptyValue {
            messageLabel.apply(textStyle: .regular(size: UIFont.labelFontSize))
        }

        dismissButton.apply(textStyle: .ultraLight(color: UIColor.textMediumDark.withAlphaComponent(0.8), size: .button - 2.0))
    }

    open override func setupControlActions() {
        super.setupControlActions()
        dismissButton.onTap = userDidTapDismissButton
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
