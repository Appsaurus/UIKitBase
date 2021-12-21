//
//  Request.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/11/17.
//

import UIKit

open class Request {
    public let route: Route
    public var urlParams: [URLQueryItem]
    public var queryParams: [URLQueryItem]
    private lazy var urlParamsDict: [String: String] = self.urlParams.dictionary

    private lazy var queryParamsDict: [String: String] = self.queryParams.dictionary

    init(route: Route,
         urlParams: [URLQueryItem]? = nil,
         queryParams: [URLQueryItem]? = nil)
    {
        self.route = route
        self.urlParams = urlParams ?? []
        self.queryParams = queryParams ?? []
    }

    /**
     Acessing url params in the route, ie. id from /video/:id

     - parameter name: Key of the param
     - returns: value of the the param
     */
    open func param(_ name: String) -> String? {
        return self.urlParamsDict[name]
    }

    /**
     Acessing query strings params in the route, ie q from /video?q=asdf

     - parameter name: Key of the param
     - returns: value of the the param
     */
    open func query(_ name: String) -> String? {
        return self.queryParamsDict[name]
    }
}

private extension Array where Element == URLQueryItem {
    var dictionary: [String: String] {
        var urlParams: [String: String] = [:]
        for param in self {
            if let value = param.value {
                urlParams[param.name] = value
            }
        }
        return urlParams
    }
}
