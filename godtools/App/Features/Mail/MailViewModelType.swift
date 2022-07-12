//
//  MailViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import MessageUI

protocol MailViewModelType {
    
    var toRecipients: [String] { get }
    var subject: String { get }
    var message: String { get }
    var isHtml: Bool { get }
    
    func finishedSendingMail(result: MFMailComposeResult, error: Error?)
}
