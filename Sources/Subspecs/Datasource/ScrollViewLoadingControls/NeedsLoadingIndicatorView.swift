//
//  NeedsLoadingIndicatorView.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 1/3/18.
//

import Swiftest
import UIKitTheme
import Layman
import DarkMagic


private extension AssociatedObjectKeys{
	static let needsLoadingIndicator = AssociatedObjectKey<BaseButton>("needsLoadingIndicator")
}

extension UIScrollView{

	public var needsLoadingIndicator: BaseButton?{
		get{
			return getAssociatedObject(for: .needsLoadingIndicator)
		}
		set{
			setAssociatedObject(newValue, for: .needsLoadingIndicator)
		}
	}

	public func showNeedsLoadingIndicator(title: String = "RELOAD", onTap: VoidClosure? = nil){
		if loadingControls.pullToRefresh.isEnabled && needsLoadingIndicator == nil{
			DispatchQueue.main.async {
				let needsLoadingIndicator = NeedsLoadingIndicator(scrollView: self)
				needsLoadingIndicator.titleMap = [.normal : title]
				needsLoadingIndicator.styleMap = [.normal : .solid(backgroundColor: .primary, textColor: .primaryContrast, font: .bold(.button))]
				self.needsLoadingIndicator = needsLoadingIndicator
				needsLoadingIndicator.onTap = onTap ?? { [weak self] in
					guard let `self` = self else { return }
					self.beginRefreshing()
					self.hideNeedsLoadingIndicator()
				}
				needsLoadingIndicator.forceAutolayoutPass()
			}
		}
	}

//    fileprivate func animateDepth() {
//        let animations: [MotionAnimation] = [.fadeIn,
//                                             .scale(1.25)]
//        needsLoadingIndicator?.animate(animations, completion: { [weak self] in
//            self?.needsLoadingIndicator?.animate(.scale())
//        })
//
//
//    }


	public func hideNeedsLoadingIndicator(){
		guard let needsLoadingIndicator = needsLoadingIndicator else { return }
		needsLoadingIndicator.removeFromSuperview()
		self.needsLoadingIndicator = nil
	}
}

extension PaginationManaged where Self: UIViewController{
	public func reloadOrShowNeedsLoadingIndicator(title: String = "LOAD NEW DATA", reloadTest: ClosureOut<Bool>? = nil){
		let shouldLoad = reloadTest?() ?? (self.currentState == .empty || !self.isCurrentlyVisibleToUser)
		guard shouldLoad else{
			showNeedsLoadingIndicator(title: title)
			return
		}

		reload()
	}

	public func reloadOrShowNeedsLoadingIndicator(title: String = "LOAD NEW DATA", onNotification name: Notification.Name, reloadTest: ClosureOut<Bool>? = nil){
		NotificationCenter.default.add(observer: self, name: name) { [weak self] in
			DispatchQueue.main.async{
				guard let `self` = self else { return }
				self.reloadOrShowNeedsLoadingIndicator(title: title, reloadTest: reloadTest)
			}
		}
	}
	public func reloadOrShowNeedsLoadingIndicator(title: String = "LOAD NEW DATA", onNotifications names: [Notification.Name], reloadTest: ClosureOut<Bool>? = nil){
		for name in names{
			reloadOrShowNeedsLoadingIndicator(onNotification: name)
		}
	}

	public func showNeedsLoadingIndicator(title: String = "LOAD NEW DATA", onTap: VoidClosure? = nil){
		paginatableScrollView.showNeedsLoadingIndicator(title: title, onTap: onTap)
	}
}

open class NeedsLoadingIndicator: BaseButton, ScrollViewObserver{

	weak var topConstraint: NSLayoutConstraint?
	let padding: CGFloat = 20.0
	public required init(scrollView: UIScrollView) {
		super.init(callDidInit: false)
		self.setupObserver(for: scrollView)
		didInitProgramatically()

	}

	open override func createSubviews() {
		super.createSubviews()
//        transition(.beginWith(modifiers: [.fadeOut]), .fadeIn, .scale(1.5))
		scrollView.addSubview(self)
		scrollView.bringSubviewToFront(self)
	}
	open override func createAutoLayoutConstraints() {
		super.createAutoLayoutConstraints()
		height.equal(to: 50)
		width.greaterThanOrEqual(to: 0.0)
        width.lessThanOrEqual(to: assertSuperview)
		topConstraint = top.equal(to: scrollView.contentOffset.y + padding)
		centerX.equalToSuperview()
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func scrollViewObserverDidObserveScroll(of scrollView: UIScrollView, to offset: CGPoint) {

		topConstraint?.constant = offset.y + padding
	}
}
