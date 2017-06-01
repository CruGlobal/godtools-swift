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
        let events = self.properties.events!.components(separatedBy: ",")
        for event in events {
            sendMessageToElement(tag: event)
        }
    }
    
}
