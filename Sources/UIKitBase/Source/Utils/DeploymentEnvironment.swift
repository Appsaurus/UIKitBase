//
//  DeploymentEnvironment.swift
//  UIKitBase
//
//  Created by Brian Strobach on 8/11/20.
//

import Foundation
import UIKit

public enum DeploymentEnvironment: String {
    case development
    case testFlight
    case appStore

    public static var isDevelopment: Bool {
        return ProcessInfo.processInfo.environment["DEVELOPMENT"] == "true"
    }

    public static var current: DeploymentEnvironment {
        if isRunningInAppStoreEnvironment {
            return .appStore
        }
        if isTestFlight {
            return .testFlight
        }

        return .development

    }


    public static var isTestFlight: Bool{
        if isSimulator {
            return false
        } else {
            if isAppStoreReceiptSandbox && !hasEmbeddedMobileProvision {
                return true
            } else {
                return false
            }
        }
    }

    public static var isRunningInAppStoreEnvironment: Bool {
        if isSimulator{
            return false
        } else {
            if isAppStoreReceiptSandbox || hasEmbeddedMobileProvision {
                return false
            } else {
                return true
            }
        }
    }

    // MARK: Private
    public static var hasEmbeddedMobileProvision: Bool{
        if let provision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"), provision.count > 0 {
            return true
        }
        return false
    }

    public static var isAppStoreReceiptSandbox: Bool {
        if isSimulator {
            return false
        }
        else if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return true
        }
        return false

    }

    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
          return true
        #else
          return false
        #endif        
    }
}

