//
//  Request.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/11/17.
//

import UIKit

open class Request {
    
    public let route: Route
    
    fileprivate var urlParams = [String: String]()
    fileprivate var queryParams = [String: String]()
    
    init(aRoute: Route, urlParams: [URLQueryItem], queryParams: [URLQueryItem]?) {
        route = aRoute
        for param in urlParams {
            if let value = param.value {
                self.urlParams[param.name] = value
            }
        }
        
        guard let queryParams = queryParams else { return }
        for param in queryParams {
            if let value = param.value {
                self.queryParams[param.name] = value
            }
        }
    }
    
    /**
        Acessing url params in the route, ie. id from /video/:id
    
        - parameter name: Key of the param
        - returns: value of the the param
    */
    open func param(_ name: String) -> String? {
        return urlParams[name]
    }
    
    /**
        Acessing query strings params in the route, ie q from /video?q=asdf
    
        - parameter name: Key of the param
        - returns: value of the the param
    */
    open func query(_ name: String) -> String? {
        return queryParams[name]
    }
    
}
