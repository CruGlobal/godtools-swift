//
//  TractLinkActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractLink {
    
    override func buttonTarget() {
        let properties = buttonProperties()
        guard let events = properties.events?.components(separatedBy: " ") else {
            return
        }
        
        for event in events {
            sendMessageToElement(listener: event)
        }
    }
    
}
