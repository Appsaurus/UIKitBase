//
//  DynamicHeightStackTableViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 8/17/17.
//
//

import Foundation
import UIKit

open class DynamicHeightStackTableViewCell: ViewBasedTableViewCell<VerticalStackView> {
    override open func createMainView() -> VerticalStackView {
        let sv = VerticalStackView()
        sv.apply(stackViewConfiguration: .equalSpacingVertical(spacing: 0.0))
        return sv
    }
}
