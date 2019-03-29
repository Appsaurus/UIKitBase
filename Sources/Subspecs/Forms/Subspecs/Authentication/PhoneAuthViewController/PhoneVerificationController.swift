//
//  PhoneVerificationController.swift
//  PhoneVerificationController
//
//  Created by Brian Strobach on 12/12/2017.
//  Copyright © 2017 Appsaurus. All rights reserved.
//

import Swiftest
import CountryPicker
import PhoneNumberKit

public protocol PhoneVerificationDelegate: class {
	func phoneVerificationControllerDidCancel()
	func phoneVerificationControllerDidVerify(phoneNumber: PhoneNumber)
    func requestVerificationCode(for phoneNumber: PhoneNumber, successVerificationId: @escaping ClosureIn<String>, failure: @escaping ErrorClosure)
    func confirmVerificationCode(verificationCode: String, verificationID: String, success: @escaping VoidClosure, failure: @escaping ErrorClosure)
}

public struct PhoneVerificationControllerConfiguration {
    
    public let animationDuration: TimeInterval
    public let phoneNumberFormConfiguration: PhoneNumberFormViewControllerConfiguration
    public let codeFormConfiguration: CodeFormViewControllerConfiguration
    public init(animationDuration: TimeInterval = 0.3,
                phoneNumberFormConfiguration: PhoneNumberFormViewControllerConfiguration = PhoneNumberFormViewControllerConfiguration(),
                codeFormConfiguration: CodeFormViewControllerConfiguration = CodeFormViewControllerConfiguration()) {
        self.animationDuration = animationDuration
        self.phoneNumberFormConfiguration = phoneNumberFormConfiguration
        self.codeFormConfiguration = codeFormConfiguration
    }
    
}


open class PhoneVerificationController<TextField: UITextField> where TextField : FormFieldViewProtocol {

    //    open lazy var entryViewController: PhoneNumberFormViewController = self.createPhoneNumberFormViewController()
    /**
     If you already have a verification ID, you can set it here to resume code verification.
     
     NOTE: not implemented yet.
     */
    public var verificationID: String?
    public var phoneNumber: PhoneNumber?
    
    open lazy var phoneNumberFormViewController: PhoneNumberFormViewController<TextField> = self.createPhoneNumberFormViewController()
	
    open var configuration: PhoneVerificationControllerConfiguration = PhoneVerificationControllerConfiguration()
	public weak var delegate: PhoneVerificationDelegate?
    open weak var navigationController: UINavigationController?
    
    public required init(configuration: PhoneVerificationControllerConfiguration = PhoneVerificationControllerConfiguration(), delegate: PhoneVerificationDelegate) {
        self.configuration = configuration
        self.delegate = delegate
    }
    
    open func present(in navigationController: UINavigationController){
        self.navigationController = navigationController
        navigationController.pushViewController(self.createPhoneNumberFormViewController(), animated: true)
    }
    
    open func presentModally(from presentingViewController: UIViewController){
        let nav = UINavigationController(rootViewController: createPhoneNumberFormViewController())
        self.navigationController = nav
        presentingViewController.present(viewController: nav)
    }
    open func createPhoneNumberFormViewController() -> PhoneNumberFormViewController<TextField>{
        let vc =  PhoneNumberFormViewController<TextField>(delegate: self, configuration: configuration.phoneNumberFormConfiguration)
        return vc
    }
    
    open func segueToCodeVerification() {
        let codeEntryVC = CodeFormViewController(delegate: self, configuration: configuration.codeFormConfiguration)
        self.navigationController?.push(codeEntryVC)
    }
}

extension PhoneVerificationController: PhoneNumberFormDelegate{
    public func phoneNumberFormViewControllerDidCancel() {
        delegate?.phoneVerificationControllerDidCancel()
    }
    
    
    public func processSelected(phoneNumber: PhoneNumber, success: @escaping VoidClosure, failure: @escaping ErrorClosure) {
        self.phoneNumber = phoneNumber
        delegate?.requestVerificationCode(for: phoneNumber, successVerificationId: {[weak self]  (verificationID) in
            self?.verificationID = verificationID
            success()
            }, failure: failure)
    }
    
    public func phoneNumberFormViewController(didSelect phoneNumber: PhoneNumber) {
        segueToCodeVerification()
    }
 
}

extension PhoneVerificationController: CodeFormDelegate{
    
    public func processVerification(of code: String, success: @escaping VoidClosure, failure: @escaping ErrorClosure) {
        delegate?.confirmVerificationCode(verificationCode: code, verificationID: self.verificationID!, success: success, failure: failure)
    }
    public func codeVerificationViewControllerDidVerifyCode() {
        guard let phoneNumber = phoneNumber else{
            assertionFailure("phoneNumber must be set before code verification step.")
            return
        }
        delegate?.phoneVerificationControllerDidVerify(phoneNumber: phoneNumber)
    }
}

