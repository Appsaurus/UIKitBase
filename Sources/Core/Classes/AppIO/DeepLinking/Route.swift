//
//  Route.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/11/17.
//

import UIKit
//swiftlint:disable force_try legacy_hashing
open class Route {
    
    enum Pattern: String {
        case RouteParam = ":[a-zA-Z0-9-_]+"
        case UrlParam = "([^/]+)"
    }
    
    enum RegexResult: Error, CustomDebugStringConvertible {
        case success(regex: String)
        case duplicateRouteParamError(route: String, urlParam: String)
        
        var debugDescription: String {
            switch self {
            case .success(let regex):
                return "successfully parsed to \(regex)"
            case .duplicateRouteParamError(let route, let urlParam):
                return "duplicate url param \(urlParam) was found in \(route)"
            }
        }
    }
    
    let routeParameter = try! NSRegularExpression(pattern: .RouteParam, options: .caseInsensitive)
    let urlParameter = try! NSRegularExpression(pattern: .UrlParam, options: .caseInsensitive)
    
    // parameterized route, ie: /video/:id
    public let route: String
    
    // route in its regular expression pattern, ie: /video/([^/]+)
    var routePattern: String?
    
    // url params found in route
    var urlParamKeys = [String]()
    
    init(aRoute: String) throws {
        route = aRoute
        switch regex() {
        case .success(let regex):
            routePattern = regex
        case .duplicateRouteParamError(let route, let urlParam):
            throw RegexResult.duplicateRouteParamError(route: route, urlParam: urlParam)
        }
    }
    
    /**
        Forms a regex pattern of the route
    
        - returns: string representation of the regex
    */
    func regex() -> RegexResult {
        let _route = "^\(route)/?$"
        var _routeRegex = NSString(string: _route)
        let matches = routeParameter.matches(in: _route, options: [],
            range: NSRange(location: 0, length: _route.count))

        // range offset when replacing :params
        var offset = 0
        
        for match in matches as [NSTextCheckingResult] {
            
            var matchWithOffset = match.range
            if offset != 0 {
                matchWithOffset = NSRange(location: matchWithOffset.location + offset, length: matchWithOffset.length)
            }
            
            // route param (ie. :id)
            let urlParam = _routeRegex.substring(with: matchWithOffset)
            
            // route param with ':' (ie. id)
            let name = (urlParam as NSString).substring(from: 1)

            // url params should be unique
            if urlParamKeys.contains(name) {
                return .duplicateRouteParamError(route: route, urlParam: name)
            } else {
                urlParamKeys.append(name)
            }
            
            // replace :params with regex
            _routeRegex = _routeRegex.replacingOccurrences(of: urlParam,
                with: Pattern.UrlParam.rawValue, options: NSString.CompareOptions.literal, range: matchWithOffset) as NSString
            
            // update offset
            offset += Pattern.UrlParam.rawValue.count - urlParam.count
        }
            
        return .success(regex: _routeRegex as String)
    }
}

// MARK: Hashable

extension Route: Hashable {
    public var hashValue: Int {
        return self.route.hashValue
    }
    
}

// MARK: Equatable

extension Route: Equatable {}

public func == (lhs: Route, rhs: Route) -> Bool {
    return lhs.route == rhs.route
}

// MARK: NSRegularExpression

extension NSRegularExpression {
    
    convenience init(pattern: Route.Pattern, options: NSRegularExpression.Options) throws {
        try self.init(pattern: pattern.rawValue, options: options)
    }
    
}
