//
//  DeepLinker.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/11/17.
//

import Foundation
import Swiftest

open class DeepLink<R: DeepLinkRoute> {
    public typealias DeepLinkAuthorizationTest = ClosureOut<Bool>

    open var route: R
    open var authorizationTest: DeepLinkAuthorizationTest?
    open var isActionable: Bool {
        return self.authorizationTest == nil || self.authorizationTest!() == true
    }

    public init(route: R, authorizationTest: DeepLinkAuthorizationTest? = nil) {
        self.route = route
        self.authorizationTest = authorizationTest
    }
}

open class DeepLinkRequest<R: DeepLinkRoute> {
    open var request: Request
    open var link: DeepLink<R>

    public init(request: Request, link: DeepLink<R>) {
        self.request = request
        self.link = link
    }
}

public extension Notification.Name {
    static let deepLinkRequested = Notification.Name("deepLinkRequested")
}

internal var singletonsStore: [String: AnyObject] = [:]
open class DeepLinker<R: DeepLinkRoute> {
    public class var shared: DeepLinker<R> {
        let storeKey = String(describing: R.self)
        if let singleton = singletonsStore[storeKey] {
            // swiftlint:disable:next force_cast
            return singleton as! DeepLinker<R>
        } else {
            let new_singleton = DeepLinker<R>()
            singletonsStore[storeKey] = new_singleton
            return new_singleton
        }
    }

    open var router: DeepLinkRouter = DeepLinkRouter()
    open var registeredDeepLinks: [DeepLink<R>] = []

    public init() {}

    open func register(deepLinks: [DeepLink<R>]) {
        for deepLink in deepLinks {
            self.router.bind(deepLink.route.rawValue, callback: { req in
                self.request = DeepLinkRequest(request: req, link: deepLink)
            })
        }
    }

    open func register(deepLinks: DeepLink<R>...) {
        self.register(deepLinks: deepLinks)
    }

    @discardableResult
    open func respond(to deepLinkURLRequest: String) -> Bool {
        guard let linkUrl = URL(string: deepLinkURLRequest), router.match(linkUrl) != nil else {
            debugLog("Invalid deeplink request:\(deepLinkURLRequest)")
            UIApplication.shared.topmostViewController?.presentAlert(title: "Invalid deeplink request.", message: "Unknown url: :\(deepLinkURLRequest)")
            return false
        }

        return self.request == nil ? false : true
    }

    open var request: DeepLinkRequest<R>? {
        didSet {
            postDeepLinkNotification()
        }
    }

    open func route(to route: R) {
        guard let url = URL(string: route.rawValue) else {
            return
        }

        self.router.match(url)
    }

    open func postDeepLinkNotification() {
        guard let request = self.request, request.link.isActionable else {
            return
        }
        DispatchQueue.main.async {
            NotificationCenter.post(name: request.link.route.notificationCenterName(), object: self)
        }
    }

    static func notificationName(for route: String) -> Notification.Name {
        return Notification.Name("deepLinkRequested_\(route)")
    }

    public func registerRoutes(withAuthorizationTest authorizationTest: DeepLink<R>.DeepLinkAuthorizationTest? = nil) {
        var deepLinks: [DeepLink<R>] = []
        R.allCases.forEach { route in
            deepLinks.append(DeepLink(route: route, authorizationTest: authorizationTest))
        }
        self.register(deepLinks: deepLinks)
    }
}

public protocol DeepLinkRoute: StringIdentifiableEnum {
    static var scheme: String { get }
}

extension DeepLinkRoute {
    public var fullPath: String {
        return "\(Self.scheme)//\(rawValue)"
    }
}

public protocol DeepLinkObserver: AnyObject {
    func observeDeepLinkNotifications()
}

public protocol DeepLinkHandler: DeepLinkObserver {
    associatedtype RouteType: DeepLinkRoute
    func deepLinkRoutes() -> [RouteType]
    func handleDeepLink()
    func respond(to deepLinkRequest: DeepLinkRequest<RouteType>)
}

extension DeepLinkHandler {
    public var deepLinker: DeepLinker<RouteType> {
        return DeepLinker<RouteType>.shared
    }
}

extension DeepLinkHandler where Self: NSObject {
    public func handleDeepLink() {
        guard let request = deepLinker.request, request.link.isActionable else {
            return
        }
        let route = request.link.route
        guard deepLinkRoutes().contains(route) else {
            return
        }
        respond(to: request)
    }

    public func observeDeepLinkNotifications() {
        self.handleDeepLink() // Run once to take care of any links posted before observation starts
        for route in deepLinkRoutes() {
            NotificationCenter.default.observe(route.notificationCenterName(), action: { [weak self] in
                DispatchQueue.main.async {
                    self?.handleDeepLink()
                }
            })
        }
    }
}

import UIKitMixinable

open class DeepLinkHandlerMixin: InitializableMixin<DeepLinkHandler> {
    override open func initProperties() {
        mixable.observeDeepLinkNotifications()
    }
}
