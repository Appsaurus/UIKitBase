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
                mainLayoutViewInsets: LayoutPadding = .constant(10))
    {
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

    open lazy var config = CellLayoutViewConfiguration()

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

    override public init(callInitLifecycle: Bool = true) {
        super.init(callInitLifecycle: callInitLifecycle)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.stackView)

        var items: [UIView] = [middleView]
        if self.config.showsLeftImageView {
            items.prepend(self.leftImageView)
        }

        if let optionalRightView = optionalRightView {
            items.append(optionalRightView)
        }

        self.stackView.stack(items).distribute(.fillProportionally)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.stackView.forceSuperviewToMatchContentSize(insetBy: self.config.mainLayoutViewInsets)
        self.middleView.width.greaterThanOrEqual(to: 1)
        self.optionalRightView?.width.greaterThanOrEqual(to: 1)
        self.middleView.enforceContentSize()
        self.optionalRightView?.enforceContentSize()
        if self.prioritizeMiddleViewWidthOverRightView {
            self.optionalRightView?.resistCompression(.high, forAxes: [.horizontal])
        } else {
            self.middleView.resistCompression(.high, forAxes: [.horizontal])
        }

        self.leftImageView.size.equal(to: self.config.leftImageViewSize)
        self.leftImageView.enforceContentSize()
        self.stackView.height.greaterThanOrEqual(to: self.stackView.arrangedSubviews)
    }
}
