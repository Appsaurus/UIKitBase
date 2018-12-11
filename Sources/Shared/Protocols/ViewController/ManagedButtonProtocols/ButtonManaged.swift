//
//  ButtonManaged.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 1/24/18.
//

import Foundation
import DinoDNA

public class ManagedButtonConfiguration: NSObject{
    var button: BaseButton?
    var position: ManagedButtonPosition
    var size: CGSize?
    
    public init(button: BaseButton? = nil, position: ManagedButtonPosition = .navBarRight, size: CGSize? = nil) {
        self.button = button
        self.position = position
        self.size = size
    }
}


public protocol ButtonManaged{
	func createManagedButton(configuration: ManagedButtonConfiguration) -> BaseButton
	func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton
}

public enum ManagedButtonPosition{
	case navBarLeft
	case navBarRight
	case floatingFooter
	case custom
}

extension ButtonManaged where Self: UIViewController{

	@discardableResult
	public func createManagedButton(configuration: ManagedButtonConfiguration = ManagedButtonConfiguration()) -> BaseButton{
		let button: BaseButton = configuration.button ?? defaultButton(configuration: configuration)
		layoutManagedButton(button: button, position: configuration.position, size: configuration.size)
		return button
	}

	public func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton{
		let button = BaseButton()
		styleManagedButton(button: button, position: configuration.position)
		return button
	}
	internal func styleManagedButton(button: BaseButton, position: ManagedButtonPosition){
		switch position{
		case .floatingFooter:
			button.styleMap = [.normal : .outlined(borderColor: .primaryContrast, backgroundColor: .primary)]
		case .custom:
			break
		default: //Nav bar
			button.styleMap = [.normal : .barButtonItemStyle]
		}
	}
	internal func layoutManagedButton(button: BaseButton, position: ManagedButtonPosition, size: CGSize? = nil){

		switch position{
		case .navBarLeft, .navBarRight:
			let item: UIBarButtonItem = UIBarButtonItem(customView: button)
			let size = size ?? button.calculateMaxButtonSize()
			button.frame.size = size
			if position == .navBarRight{
				button.titleLabel.textAlignment =  .right
				self.navigationItem.rightBarButtonItem = item
			}
			else{
				button.titleLabel.textAlignment =  .left
				self.navigationItem.leftBarButtonItem = item
			}

			if #available(iOS 11, *) {
				button.autoSize(to: size, relatedBy: .greaterThanOrEqual)
			}
			else{
				item.customView?.frame.size = button.frame.size
				self.navigationController?.navigationBar.setNeedsLayout()
			}
		case .floatingFooter:
			let footer = FooterView<BaseButton>(contentView: button, contentViewInsets: UIEdgeInsets(padding: 10))
			self.add(footerView: footer, height: size?.height)
		case .custom:
			break
		}
	}
}
