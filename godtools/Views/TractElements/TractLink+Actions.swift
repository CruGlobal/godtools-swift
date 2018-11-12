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
        for analyticEvent in properties.analyticsButtonUserInfo {
            let userInfo = TractAnalyticEvent.convertToDictionary(from: analyticEvent)
            sendNotificationForAction(userInfo: userInfo)
        }
        let events = properties.events.components(separatedBy: " ")
        for event in events {
            _ = sendMessageToElement(listener: event)
        }
    }
    
}
