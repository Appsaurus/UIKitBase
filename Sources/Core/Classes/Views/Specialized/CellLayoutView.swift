//
//  ModularStackViews.swift
//  Pods
//
//  Created by Brian Strobach on 7/28/17.
//
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

public struct CellLayoutViewConfiguration {
    public var showsLeftImageView: Bool
    public var leftImageViewSize: CGSize
    public var optionalRightViewMinimumWidth: CGFloat
    public var mainLayoutViewInsets: LayoutPadding
    public init(showsLeftImageView: Bool = true,
                leftImageViewSize: CGSize = CGSize(side: 45.0),
                optionalRightViewMinimumWidth: CGFloat = 60.0,
                mainLayoutViewInsets: LayoutPadding = .constant(10)) {
        self.showsLeftImageView = showsLeftImageView
        self.leftImageViewSize = leftImageViewSize
        self.optionalRightViewMinimumWidth = optionalRightViewMinimumWidth
        self.mainLayoutViewInsets = mainLayoutViewInsets
    }
}

open class CellLayoutView<MV: UIView>: BaseView {
    open var stackView = StackView()
        .on(.horizontal)
        .distribute(.fill)
        .align(.center)
        .spacing(6)

    open lazy var config: CellLayoutViewConfiguration = CellLayoutViewConfiguration()

    open lazy var optionalRightView: UIView? = nil
    open var prioritizeMiddleViewWidthOverRightView: Bool = true

    open lazy var leftImageView: BaseImageView = {
        let iv = BaseImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    open lazy var middleView: MV = {
        self.createMainView()
    }()

    open func createMainView() -> MV {
        return MV()
    }

    // MARK: Initialization

    public required init(config: CellLayoutViewConfiguration? = nil, optionalRightView: UIView? = nil) {
        super.init(callInitLifecycle: false)
        self.optionalRightView = optionalRightView
        if let config = config {
            self.config = config
        }
        initLifecycle(.programmatically)
    }

    public override init(callInitLifecycle: Bool = true) {
        super.init(callInitLifecycle: callInitLifecycle)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(stackView)

        var items: [UIView] = [middleView]
        if config.showsLeftImageView {
            items.prepend(leftImageView)
        }

        if let optionalRightView = optionalRightView {
            items.append(optionalRightView)
        }

        stackView.stack(items).distribute(.fillProportionally)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        stackView.forceSuperviewToMatchContentSize(insetBy: config.mainLayoutViewInsets)
        middleView.width.greaterThanOrEqual(to: 0)
        optionalRightView?.width.greaterThanOrEqual(to: 0)
        if prioritizeMiddleViewWidthOverRightView {
            middleView.enforceContentSize()
            optionalRightView?.resistCompression(.high)
            optionalRightView?.hugContent(.high)
        }
        else {
            middleView.resistCompression(.high)
            middleView.hugContent(.high)
            optionalRightView?.resistCompression()
            optionalRightView?.hugContent()
        }

        leftImageView.size.equal(to: config.leftImageViewSize)
        leftImageView.enforceContentSize()
    }
}
