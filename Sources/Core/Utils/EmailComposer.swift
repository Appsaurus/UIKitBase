//
//  EmailComposer.swift
//  Pods
//
//  Created by Brian Strobach on 6/30/16.
//
//

import Foundation
import MessageUI

open class EmailComposer: NSObject, MFMailComposeViewControllerDelegate{
    weak open var presenter: UIViewController?
    //var mailComposerVC: MFMailComposeViewController!
    
    public init(presenter: UIViewController? = UIApplication.topmostViewController){
        self.presenter = presenter
        super.init()
    }
    
    open func sendEmail(recipients: [String]? = nil, subject: String? = nil){
        if MFMailComposeViewController.canSendMail(){
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            mailComposerVC.setToRecipients(recipients)
            mailComposerVC.setSubject(subject ?? "")
            
            presenter?.present(mailComposerVC, animated: true, completion: nil)
        }
        else{
            presenter?.presentAlert(title: "Could Not Send Email", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.")
        }
    }
    @objc open func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        presenter?.dismiss(animated: true, completion: nil)
    }
}
