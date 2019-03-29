//
//  BaseImageView.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseImageViewProtocol: BaseViewProtocol {}

extension BaseImageViewProtocol where Self: UIImageView {
    public var baseImageViewProtocolMixins: [LifeCycle] {
        return [] + baseViewProtocolMixins
    }
}

open class BaseImageView: MixinableImageView, BaseImageViewProtocol {
    open var tintsImages: Bool = false

    open override var image: UIImage? {
        set {
            if self.tintsImages {
                super.image = newValue?.withRenderingMode(.alwaysTemplate)
            } else { super.image = newValue }
        }
        get {
            return super.image
        }
    }

    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseImageViewProtocolMixins
    }

    open override func didInit() {
        super.didInit()
        contentMode = .scaleAspectFit
        clipsToBounds = true
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
