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
    override open func createMixins() -> [LifeCycle] {
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

    override open func createSubviews() {
        super.createSubviews()
        contentView.addSubview(self.imageView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.imageView.pinToSuperview()
    }
}

open class BaseLabeledCollectionViewCell: BaseCollectionViewCell {
    open var label: UILabel = UILabel()

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        self.label.textAlignment = .center
    }

    override open func createSubviews() {
        super.createSubviews()
        contentView.addSubview(self.label)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.label.pinToSuperview()
        //        label.centerInSuperview()
        //        label.autoMatchSize(of: self.contentView, relatedBy: .lessThanOrEqual)
    }
}

open class BaseCollectionReusableView: MixinableCollectionReusableView, BaseViewProtocol {
    override open func createMixins() -> [LifeCycle] {
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
