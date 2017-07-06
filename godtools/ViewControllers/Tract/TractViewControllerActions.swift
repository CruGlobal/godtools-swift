//
//  TractViewControllerActions.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension TractViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail(notification: Notification) {
        if MFMailComposeViewController.canSendMail() {
            guard let dictionary = notification.userInfo as? [String: Any] else {
                return
            }
            
            displayEmailCompose(dictionary: dictionary)
        } else {
            displayEmailErrorMessage()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func displayEmailCompose(dictionary: [String: Any]) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setSubject(dictionary["subject"] as! String)
        composeVC.setMessageBody(dictionary["content"] as! String, isHTML: dictionary["html"] as! Bool)
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func displayEmailErrorMessage() {
        let alert = UIAlertController(title: "GodTools", message: "error_can_not_send_email".localized, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendPageToAnalytics() {
        let screenName = "\(self.currentPage)"
        sendScreenViewNotification(screenName: screenName)
    }
    
}
