//
//  ExampleObject.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 10/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKitBase
import Fakery

let faker = Faker(locale: Locale.current.regionCode!)
open class ExampleObject: Equatable{
    
    open var name: String = faker.name.name()
    open var company: String = faker.company.name()
    
    public static func ==(lhs: ExampleObject, rhs: ExampleObject) -> Bool {
        return lhs === rhs
    }

    
}
