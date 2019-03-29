//
//  CornerBadgeView.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 2/16/18.
//

import Foundation
import Swiftest
import Layman

open class CornerBadgeView<S : Hashable>: StatefulBadgeView<S>{
	open override func createAutoLayoutConstraints() {
		super.createAutoLayoutConstraints()
        size.equal(to: badgeHeight)		
	}

	open override func applyCurrentViewStyle() {
		//Do nothing. Override parent implementation of styling since this needs to be done in draw rect in this case
		backgroundColor = .clear
		setNeedsDisplay()
	}
	open override func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let viewStyle = viewStyleMap[state] else{
			return
		}

		//Only truly supports inside layout
		var polygonVertices: [CGPoint] = []
		switch position{
			case .topRight, .topRightInside:
				polygonVertices = [self.bounds.topLeft, self.bounds.topRight, self.bounds.bottomRight]
			case .topLeft, .topLeftInside:
				polygonVertices = [self.bounds.bottomLeft, self.bounds.topLeft, self.bounds.topRight]
		}
		DrawingUtils.draw(polygon: polygonVertices, style: viewStyle)
	}
}
