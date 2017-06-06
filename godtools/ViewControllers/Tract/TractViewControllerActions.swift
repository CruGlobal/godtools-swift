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
        guard let dictionary = notification.userInfo as? [String: Any] else {
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setSubject(dictionary["subject"] as! String)
        composeVC.setMessageBody(dictionary["content"] as! String, isHTML: dictionary["html"] as! Bool)
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
