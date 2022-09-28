//
//  DividerView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/16/22.
//

import Layman

public class DividerView: BaseView {
    public var thickness: LayoutConstant
    public var color: UIColor{
        didSet {
            style()
        }
    }

    public init(thickness: LayoutConstant = 1.0, color: UIColor = .tableViewCellSeparatorColor) {
        self.thickness = thickness
        self.color = color
        super.init(callInitLifecycle: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func style() {
        super.style()
        backgroundColor = color
    }
    public override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        height.equal(to: thickness)
    }
}

public class LabeledDividerView: BaseView {
    public var thickness: LayoutConstant
    public var color: UIColor {
        didSet {
            style()
        }
    }
    public var contentView: UIView
    public lazy var leftLine = DividerView(thickness: thickness, color: color)
    public lazy var rightLine = DividerView(thickness: thickness, color: color)

    public override func style() {
        super.style()
        [leftLine, rightLine].forEach { (line) in
            line.color = color
        }
    }
    public init(thickness: LayoutConstant = 1.0,
                color: UIColor = .tableViewCellSeparatorColor,
                contentView: UIView) {
        self.thickness = thickness
        self.color = color
        self.contentView = contentView
        super.init(callInitLifecycle: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func createSubviews() {
        super.createSubviews()
        addSubviews(leftLine,
                    contentView,
                    rightLine)
    }

    public override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        [leftLine, contentView, rightLine].centerY.equal(to: self)
        [leftLine, contentView, rightLine].stack(.leftToRight, spacing: 10)
        leftLine.width.equal(to: rightLine)
        leftLine.leading.equalToSuperview()
        rightLine.trailing.equalToSuperview()
        contentView.enforceContentSize()
        contentView.size.greaterThanOrEqual(to: 1)
    }
}
