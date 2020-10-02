//
//  BaseContainedCollectionViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/9/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Foundation
import UIKitMixinable

extension BaseCollectionViewControllerProtocol where Self: BaseContainedCollectionViewController {
    public var baseCollectionViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BaseContainedCollectionViewController: BaseContainerViewController, BaseCollectionViewControllerProtocol, UICollectionViewDelegate {
    private var _layout: UICollectionViewLayout = UICollectionViewFlowLayout()
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseCollectionViewControllerProtocolMixins
    }

    open lazy var collectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: self._layout).then { cv in
        cv.backgroundColor = .clear
    }

    public init(collectionViewLayout: UICollectionViewLayout) {
        super.init(callInitLifecycle: false)
        self._layout = collectionViewLayout
        initLifecycle(.programmatically)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func initProperties() {
        super.initProperties()
        containedView = self.collectionView
    }

    override open func setupDelegates() {
        super.setupDelegates()
        self.collectionView.delegate = self
    }
}
