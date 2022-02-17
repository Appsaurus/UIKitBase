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

public struct ExampleObject: Hashable, Codable{
    
    public var name: String = faker.name.name()
    public var company: String = faker.company.name()
}
