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
        let properties = emailProperties()
        let userInfo = ["subject": properties.subject, "content": properties.content, "html": properties.html] as [String : Any]
        NotificationCenter.default.post(name: .sendEmailFromTractForm, object: nil, userInfo: userInfo)
    }
    
}
