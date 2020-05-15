//
//  TractLink.swift
//  godtools
//
//  Created by Devserker on 5/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractLink: TractButton {
    
    // MARK: - Setup
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.font = .gtRegular(size: 16.0)
        return properties
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        
        let properties = buttonProperties()
        properties.backgroundColor = .clear
    }

    override func buttonTextColor(localColor: UIColor?) -> UIColor {
        return localColor ?? page?.pageProperties().primaryColor ?? manifestProperties.primaryColor
    }
}

// MARK: - Actions

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
