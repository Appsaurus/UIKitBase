//
//  CornerBadgeView.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 2/16/18.
//

import Foundation
import Layman
import Swiftest

open class CornerBadgeView<S: Hashable>: StatefulBadgeView<S> {
    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        size.equal(to: badgeHeight)
    }

    override open func applyCurrentViewStyle() {
        // Do nothing. Override parent implementation of styling since this needs to be done in draw rect in this case
        backgroundColor = .clear
        setNeedsDisplay()
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let viewStyle = viewStyleMap[state] else {
            return
        }

        // Only truly supports inside layout
        var polygonVertices: [CGPoint] = []
        switch position {
        case .topRight, .topRightInside:
            polygonVertices = [bounds.topLeft, bounds.topRight, bounds.bottomRight]
        case .topLeft, .topLeftInside:
            polygonVertices = [bounds.bottomLeft, bounds.topLeft, bounds.topRight]
        }
        DrawingUtils.draw(polygon: polygonVertices, style: viewStyle)
    }
}
