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

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return .default(for: self)
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}

    open func viewModelForErrorState(_ error: Error) -> StatefulViewViewModel {
        return .error(error)
    }

    //MARK: - Reloadable
    open func reload(completion: @escaping () -> Void) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }
}
