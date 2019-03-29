//
//  Router.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/11/17.
//

import Swiftest
import UIKit
public typealias RouteHandler = (_ req: Request) -> Void

open class Router {
    private var orderedRoutes = [Route]()
    private var routes = [Route: RouteHandler]()

    public init() {}
    /**
     Binds a route to a router

     - parameter aRoute: A string reprsentation of the route. It can include url params, for example id in /video/:id
     - parameter callback: Triggered when a route is matched
     */
    open func bind(_ aRoute: String, callback: RouteHandler? = nil) {
        do {
            let route = try Route(aRoute: aRoute)
            orderedRoutes.append(route)
            if let callback = callback { routes[route] = callback }
        } catch let error as Route.RegexResult {
            debugLog(error)
        } catch {
            fatalError("[\(aRoute)] unknown bind error")
        }
    }

    /**
     Matches an incoming URL to a route present in the router. Returns nil if none are matched.

     - parameter url: An URL of an incoming request to the router
     - returns: The matched route or nil
     */
    open func match(_ url: URL) -> Route? {
        guard let routeComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        // form the host/path url
        let host = routeComponents.host.flatMap { "/\($0)" } ?? ""
        let path = routeComponents.path
        let routeToMatch = "\(host)\(path)"
        let queryParams = routeComponents.queryItems
        var urlParams = [URLQueryItem]()

        // match the route!
        for route in orderedRoutes {
            guard let pattern = route.routePattern else {
                continue
            }

            var regex: NSRegularExpression

            do {
                regex = try NSRegularExpression(pattern: pattern,
                                                options: .caseInsensitive)
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }

            let matches = regex.matches(in: routeToMatch, options: [],
                                        range: NSRange(location: 0, length: routeToMatch.count))

            // check if routeToMatch has matched
            if matches.count > 0 {
                let match = matches[0]

                // gather url params
                for i in 1 ..< match.numberOfRanges {
                    let name = route.urlParamKeys[i - 1]
                    let value = (routeToMatch as NSString).substring(with: match.range(at: i))
                    urlParams.append(URLQueryItem(name: name, value: value))
                }

                // fire callback
                if let callback = routes[route] {
                    callback(Request(aRoute: route, urlParams: urlParams, queryParams: queryParams))
                }

                // return route that was matched
                return route
            }
        }

        // nothing matched
        return nil
    }
}
