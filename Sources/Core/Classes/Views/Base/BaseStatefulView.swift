//
//  BaseStatefulView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/4/18.
//

import UIKit
import UIKitMixinable

open class BaseStatefulView: BaseView, StatefulViewController {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + [StatefulViewMixin(self)]
    }
    
    // MARK: StatefulViewController
    open func startLoading() {}
    
    open func customizeStatefulViews() {}
    
    open func createStatefulViews() -> StatefulViewMap {
        return .default
    }
    
    open func willTransition(to state: State) {}
    
    open func didTransition(to state: State) {}
    
}
