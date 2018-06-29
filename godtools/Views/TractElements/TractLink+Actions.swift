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
        if let analyticEvent = properties.analyticsButtonUserInfo.first {
            let userInfo = TractAnalyticEvent.convertToDictionary(from: analyticEvent)
            sendNotificationForAction(userInfo: userInfo)
        }
        let events = properties.events.components(separatedBy: " ")
        for event in events {
            sendMessageToElement(listener: event)
        }
    }
    
}
