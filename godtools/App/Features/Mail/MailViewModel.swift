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
        
    let toRecipients: [String]
    let subject: String
    let message: String
    let isHtml: Bool
    
    required init(toRecipients: [String], subject: String, message: String, isHtml: Bool, finishedSendingMailHandler: CallbackHandler) {
        self.toRecipients = toRecipients
        self.subject = subject
        self.message = message
        self.isHtml = isHtml
        self.finishedSendingMailHandler = finishedSendingMailHandler
    }
    
    func finishedSendingMail(result: MFMailComposeResult, error: Error?) {
        finishedSendingMailHandler.handle()
    }
}
