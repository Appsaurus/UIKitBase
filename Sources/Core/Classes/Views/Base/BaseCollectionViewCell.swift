//
//  BaseCollectionViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseCollectionViewCellProtocol: BaseViewProtocol {}

extension BaseCollectionViewCellProtocol where Self: UICollectionViewCell {
    public var baseCollectionViewCellProtocolMixins: [LifeCycle] {
        return [] + baseViewProtocolMixins
    }
}

open class BaseCollectionViewCell: MixinableCollectionViewCell, BaseCollectionViewCellProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseCollectionViewCellProtocolMixins
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
        apply(collectionViewCellStyle: .defaultStyle)
    }
}

open class BaseImageCollectionViewCell: BaseCollectionViewCell {
    open var imageView: BaseImageView = BaseImageView()

    open override func createSubviews() {
        super.createSubviews()
        contentView.addSubview(imageView)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        imageView.pinToSuperview()
    }
}

open class BaseLabeledCollectionViewCell: BaseCollectionViewCell {
    open var label: UILabel = UILabel()

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        label.textAlignment = .center
    }

    open override func createSubviews() {
        super.createSubviews()
        contentView.addSubview(label)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        label.pinToSuperview()
        //        label.centerInSuperview()
        //        label.autoMatchSize(of: self.contentView, relatedBy: .lessThanOrEqual)
    }
}

open class BaseCollectionReusableView: MixinableCollectionReusableView, BaseViewProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseViewProtocolMixins
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

    open func style() {}
}
