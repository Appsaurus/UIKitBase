//
//  AuthControllerManager.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import Swiftest


public protocol AuthControllerManagerDelegate: AuthControllerDelegate{
	func didBeginSessionRestore<R, V>(for authController: AuthController<R, V>)
	func logoutDidFail<R, V>(for controller: AuthController<R, V>, with error: Error?)
	func logoutDidSucceed<R, V>(for controller: AuthController<R, V>)
	func authenticationDidBegin()
	func authenticationDidFail(error: Error)
	func authenticationDidSucceed(successResponse: Any)
	func logoutDidSucceed()
	func logoutDidFail(error: Error?)
	func beginSignup(success: @escaping (Any) -> Void, failure: @escaping ErrorClosure)
}

open class BaseAuthControllerManager: AuthControllerDelegate{

	public required init(delegate: AuthControllerManagerDelegate){
		self.delegate = delegate
	}

	weak var delegate: AuthControllerManagerDelegate?


	//MARK: AuthController specific
	open func noExistingAuthenticationSessionFound<R, V>(for controller: AuthController<R, V>) where V : UIView, V : AuthView {
		delegate?.noExistingAuthenticationSessionFound(for: controller)
	}

	open func authenticationDidBegin<R, V>(controller: AuthController<R, V>) where V : UIView, V : AuthView {
		delegate?.authenticationDidBegin(controller: controller)
		authenticationDidBegin()
	}

	open func authenticationDidFail<R, V>(controller: AuthController<R, V>, error: Error) where V : UIView, V : AuthView {
		delegate?.authenticationDidFail(controller: controller, error: error)
		authenticationDidFail(error: error)
	}

	open func authenticationDidSucceed<R, V>(controller: AuthController<R, V>, successResponse: Any) where V : UIView, V : AuthView {
		delegate?.authenticationDidSucceed(controller: controller, successResponse: successResponse)
		authenticationDidSucceed(successResponse: successResponse)
	}

	open func logoutDidFail<R, V>(for controller: AuthController<R, V>, with error: Error?) where V : UIView, V : AuthView {
		delegate?.logoutDidFail(for: controller, with: error)
		logoutDidFail(error: error)
	}

	open func logoutDidSucceed<R, V>(for controller: AuthController<R, V>) where V : UIView, V : AuthView {
		delegate?.logoutDidSucceed(for: controller)
		logoutDidSucceed()
	}

	//MARK: Any AuthController
	open func logoutDidSucceed(){
		delegate?.logoutDidSucceed()
	}
	open func logoutDidFail(error: Error?){
		delegate?.logoutDidFail(error: error)
	}

	open func authenticationDidBegin() {
		delegate?.authenticationDidBegin()
	}

	open func authenticationDidFail(error: Error) {
		delegate?.authenticationDidFail(error: error)
	}

	open func authenticationDidSucceed(successResponse: Any) {
		delegate?.authenticationDidSucceed(successResponse: successResponse)
	}

	//MARK: Logout
	open func logout(){
		logout(success: logoutDidSucceed, failure: logoutDidFail)
	}

	open func logout(success: VoidClosure, failure: OptionalErrorClosure) {
		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)

	}


//	open func attemptSessionRestoreForMostRecentAuthController(){
//		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//	}
	open func attemptSessionRestore<R, V>(for authController: AuthController<R, V>){
		authController.attemptSessionRestore(success: {[weak self] (user: Any) in
			self?.authenticationDidSucceed(controller: authController, successResponse: user)
		}) {[weak self] (error) in
			guard let error = error else {
				//No session exists
				self?.noExistingAuthenticationSessionFound(for: authController)
				return
			}
			self?.authenticationDidFail(controller: authController, error: error)
		}
	}


}
