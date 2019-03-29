//
//  ScrollViewObserver.swift
//  Pods
//
//  Created by Brian Strobach on 6/25/17.
//
//

import Swiftest
import DarkMagic

public protocol ScrollViewObserver: KVObserver {
	var scrollView: UIScrollView { get }
	func setupObserver(for scrollView: UIScrollView)
    func scrollViewObserverDidObserveScroll(of scrollView: UIScrollView, to offset: CGPoint)
}

private extension AssociatedObjectKeys {
	static let scrollView = AssociatedObjectKey<UIScrollView>("scrollView")
}
extension ScrollViewObserver where Self: NSObject {

    public internal(set) var scrollView: UIScrollView {
        get {
			return getAssociatedObject(for: .scrollView, initialValue: UIScrollView())
        }
        set {
            setAssociatedObject(newValue, for: .scrollView)
        }
    }
    
	public func setupObserver(for scrollView: UIScrollView) {
		self.scrollView = scrollView
		observe(object: scrollView, \.contentOffset) { [weak self] (scrollView, change) in
			guard let `self` = self else { return }
			guard let newOffset = change.newValue else { return }
			self.scrollViewObserverDidObserveScroll(of: scrollView, to: newOffset)
		}
    }
    
}
