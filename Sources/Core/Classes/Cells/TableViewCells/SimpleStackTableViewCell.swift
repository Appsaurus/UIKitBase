//
//  SimpleStackTableViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 7/10/17.
//
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

open class ModularTableViewCell<MV, CLV: CellLayoutView<MV>> : ViewBasedTableViewCell<CLV> {
    
}

open class ModularStackTableViewCell<StackedView, MSV: ModularStackView<StackedView>>: ViewBasedTableViewCell<MSV> {

    open var config: CellLayoutViewConfiguration?
    
    open lazy var stackView: GrowingStackView<StackedView> = {
        return self.view.stackView        
    }()
    
    open var leftImageView: BaseImageView {
        return self.view.leftImageView
    }
    
    open var optionalRightView: UIView? {
        return nil
    }
    
    open override func createMainView() -> MSV {
        return MSV(config: config, optionalRightView: optionalRightView)        
    }
    
}

open class ModularTextFieldStackTableViewCell<MSV: ModularStackView<UITextField>>: ModularStackTableViewCell<UITextField, MSV> {}
open class ModularLabelStackTableViewCell<MSV: ModularStackView<UILabel>>: ModularStackTableViewCell<UILabel, MSV> {}
open class ModularButtonStackTableViewCell<MSV: ModularStackView<BaseButton>>: ModularStackTableViewCell<BaseButton, MSV> {}

open class SimpleStackTableViewCell<StackedView: UIView>: ModularStackTableViewCell<StackedView, ModularStackView<StackedView>> {
    
    open override func createMainView() -> ModularStackView<StackedView> {
        return ModularStackView<StackedView>(config: config, optionalRightView: optionalRightView)
    }
    
}

open class DualStackTableViewCell<StackedView: UIView, RightStackedView: UIView>: ModularStackTableViewCell<StackedView, DualModularStackview<StackedView, RightStackedView>> {
    
    open lazy var rightStack: GrowingStackView<RightStackedView> = {
        return self.view.rightStack
    }()
    
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        rightStack.apply(stackViewConfiguration: self.rightStackLayoutStyle)
    }
    
    open var rightStackLayoutStyle: StackViewConfiguration {
        return .equalSpacingVertical(spacing: 3.0)
    }
}

open class LabelStackTableViewCell: SimpleStackTableViewCell<UILabel> {
    
    open var primaryLabel: UILabel { return self.stackView.stackedView(at: 0)}
    open var secondaryLabel: UILabel { return self.stackView.stackedView(at: 1)}
    open var tertiaryLabel: UILabel { return self.stackView.stackedView(at: 2)}

    open override func style() {
        super.style()
        primaryLabel.apply(textStyle: TextStyle(color: .textDark, font: .medium(17.0)))
        secondaryLabel.apply(textStyle: TextStyle(color: .textMedium, font: .regular(14.0)))
        tertiaryLabel.apply(textStyle: TextStyle(color: .textMedium, font: .regular(14.0)))
    }
}

open class ButtonStackTableViewCell: SimpleStackTableViewCell<UIButton> {
    
    open var primaryButton: UIButton { return self.stackView.stackedView(at: 0)}
    open var secondaryButton: UIButton { return self.stackView.stackedView(at: 0)}
    open var tertiaryButton: UIButton { return self.stackView.stackedView(at: 0)}
    
    open override func style() {
        super.style()
        primaryButton.apply(textStyle: TextStyle(color: .textDark, font: .medium(16.0)))
        secondaryButton.apply(textStyle: TextStyle(color: .textMedium, font: .regular(13.0)))
        tertiaryButton.apply(textStyle: TextStyle(color: .textMedium, font: .regular(13.0)))
    }
}
