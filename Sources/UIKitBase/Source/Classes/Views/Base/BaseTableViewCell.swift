//
//  BaseTableViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseTableViewCellProtocol: BaseViewProtocol {}

public extension BaseTableViewCellProtocol where Self: UITableViewCell {
    var baseTableViewCellProtocolMixins: [LifeCycle] {
        return [] + baseViewProtocolMixins
    }
}

open class BaseTableViewCell: MixinableTableViewCell, BaseTableViewCellProtocol {
//    open var subviewsUnmodifiedBySelectionState: [UIView] = []

    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTableViewCellProtocolMixins
    }

    // MARK: NotificationObserver

    open func notificationsToObserve() -> [Notification.Name] {
        return []
    }

    open func notificationClosureMap() -> NotificationClosureMap {
        return [:]
    }

    open func didObserve(notification: Notification) {}

    // MARK: Styleable

    open func style() {
        apply(tableViewCellStyle: .defaultStyle)
    }

//    //Selection and highlight behavior
//    override open func setSelected(_ selected: Bool, animated: Bool) {
//        let viewStates = subviewsUnmodifiedBySelectionState.map { (view) -> (UIView, UIColor?) in
//            return (view, view.backgroundColor)
//        }
//        super.setSelected(selected, animated: animated)
//
//        viewStates.forEach { (viewState) in
//            viewState.0.backgroundColor = viewState.1
//        }
//    }
//
//    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        let viewStates = subviewsUnmodifiedBySelectionState.map { (view) -> (UIView, UIColor?) in
//            return (view, view.backgroundColor)
//        }
//        super.setHighlighted(highlighted, animated: animated)
//
//        viewStates.forEach { (viewState) in
//            viewState.0.backgroundColor = viewState.1
//        }
//    }
}
