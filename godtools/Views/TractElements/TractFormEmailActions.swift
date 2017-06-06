//
//  TractFormEmailActions.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractForm {
    
    func sendEmail(recipient: String, subject: String, content: String) {
        let userInfo = ["recipient": recipient, "subject": subject, "content": content, "html": true]
        NotificationCenter.default.post(name: .sendEmailFromTractForm, object: nil, userInfo: userInfo)
    }
    
}
