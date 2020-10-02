//
//  DynamicSizeCollectionViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 9/28/17.
//
//

import Layman
import UIKitTheme

open class DynamicSizeCollectionViewCell: BaseCollectionViewCell {
    public var mainLayoutView = UIView()
    public lazy var mainLayoutViewInsets: LayoutPadding = {
        .zero
    }()

    override open func createSubviews() {
        super.createSubviews()
        contentView.addSubview(self.mainLayoutView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.mainLayoutView.forceSuperviewToMatchContentSize(insetBy: self.mainLayoutViewInsets)
    }

//    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        guard let fixedDimension = fixedDimension else { return super.preferredLayoutAttributesFitting(layoutAttributes) }
//        forceAutolayoutPass()
//        let size = calculateDynamicSize(fixedDimension: fixedDimension)
//        var newFrame = layoutAttributes.frame
//        // note: don't change the width
//        newFrame.size = size
//        layoutAttributes.frame = newFrame
//        return layoutAttributes
//    }

    open func calculateDynamicSize(fixedDimension: DynamicSizeCellFixedDimension, layoutSize: CGSize = UIView.layoutFittingCompressedSize) -> CGSize {
        var tempConstraint: NSLayoutConstraint!
        switch fixedDimension {
        case let .width(width):
            tempConstraint = contentView.width.equal(to: width)
        case let .height(height):
            tempConstraint = contentView.height.equal(to: height)
        }

        let size = contentView.systemLayoutSizeFitting(layoutSize)
        contentView.removeConstraint(tempConstraint)
        return size
    }
}

public enum DynamicSizeCellFixedDimension {
    case width(size: CGFloat)
    case height(size: CGFloat)
}
