//
//  MailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import MessageUI

class MailViewModel: MailViewModelType {
        
    private let finishedSendingMailHandler: CallbackHandler
    
    private weak var flowDelegate: FlowDelegate?
    
    let toRecipients: [String]
    let subject: String
    let message: String
    let canSendViaMailApp: Bool
    
    required init(flowDelegate: FlowDelegate, toRecipients: [String], subject: String, message: String, finishedSendingMailHandler: CallbackHandler) {
        self.flowDelegate = flowDelegate
        self.toRecipients = toRecipients
        self.subject = subject
        self.message = message
        self.canSendViaMailApp = MFMailComposeViewController.canSendMail()
        self.finishedSendingMailHandler = finishedSendingMailHandler
    }
    
    func finishedSendingMail(result: MFMailComposeResult, error: Error?) {
        finishedSendingMailHandler.handle()
    }
}
