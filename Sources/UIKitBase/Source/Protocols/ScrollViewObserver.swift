//
//  ScrollViewObserver.swift
//  Pods
//
//  Created by Brian Strobach on 6/25/17.
//
//

import DarkMagic
import Swiftest

public protocol ScrollViewObserver: KVObserver {
    var scrollView: UIScrollView? { get }
    func setupObserver(for scrollView: UIScrollView)
    func scrollViewObserverDidObserveScroll(of scrollView: UIScrollView, to offset: CGPoint)
}

private extension AssociatedObjectKeys {
    static let scrollView = AssociatedObjectKey<UIScrollView>("scrollView", policy: .weak)
}

public extension ScrollViewObserver where Self: NSObject {
    internal(set) var scrollView: UIScrollView? {
        get {
            return self[.scrollView]
        }
        set {
            self[.scrollView] = newValue
        }
    }

    func setupObserver(for scrollView: UIScrollView) {
        self.scrollView = scrollView
        observe(object: scrollView, \.contentOffset) { [weak self] scrollView, change in
            guard let self = self else { return }
            guard let newOffset = change.newValue else { return }
            self.scrollViewObserverDidObserveScroll(of: scrollView, to: newOffset)
        }
    }
}
