//
//  BaseTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import Swiftest
import UIKit
import UIKitMixinable

public protocol BaseTableViewControllerProtocol: BaseViewControllerProtocol {}

extension BaseTableViewControllerProtocol where Self: UITableViewController {
    public var baseTableViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BaseTableViewController: MixinableTableViewController, BaseTableViewControllerProtocol {
    private var cellHeightsDictionary: [String: CGFloat] = [:]

    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTableViewControllerProtocolMixins
    }

    override open func setupDelegates() {
        super.setupDelegates()
        self.tableView.delegate = self
    }

    // MARK: Orientation

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return currentSupportedInterfaceOrientation
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimation
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override open var prefersStatusBarHidden: Bool {
        return statusBarHidden
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
        applyBaseViewStyle()
        self.tableView.apply(tableViewStyle: .defaultStyle)
    }

    // MARK: Reloadable

    open func reload(completion: @escaping () -> Void) {
        reloadFunction?(completion)
    }

    // MARK: StatefulViewController

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return .default(for: self)
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}

    open func viewModelForErrorState(_ error: Error) -> StatefulViewViewModel {
        return .error(error, retry: loadAsyncData)
    }

    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsDictionary[indexPath.cacheKey] = cell.frame.size.height
    }

    override open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeightsDictionary[indexPath.cacheKey] ?? UITableView.automaticDimension
    }
}

private extension IndexPath {
    var cacheKey: String {
        return String(describing: self)
    }
}
