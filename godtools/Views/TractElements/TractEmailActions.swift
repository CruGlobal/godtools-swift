//
//  TractEmailActions.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractEmail {
    
    override func receiveMessage() {
        let userInfo = ["subject": self.properties.subject, "content": self.properties.content, "html": self.properties.html] as [String : Any]
        NotificationCenter.default.post(name: .sendEmailFromTractForm, object: nil, userInfo: userInfo)
    }
    
}
