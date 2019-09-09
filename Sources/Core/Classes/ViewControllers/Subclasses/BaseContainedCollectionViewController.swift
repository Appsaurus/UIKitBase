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
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseCollectionViewControllerProtocolMixins
    }

    open lazy var collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                      collectionViewLayout: self._layout).then { cv in
        cv.backgroundColor = .clear
    }

    public init(collectionViewLayout: UICollectionViewLayout) {
        super.init(callInitLifecycle: false)
        _layout = collectionViewLayout
        initLifecycle(.programmatically)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func initProperties() {
        super.initProperties()
        containedView = collectionView
    }

    open override func setupDelegates() {
        super.setupDelegates()
        collectionView.delegate = self
    }
}
