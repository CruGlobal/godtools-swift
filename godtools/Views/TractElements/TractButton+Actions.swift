//
//  TractButtonActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractButton {

    func buttonTarget() {
        getParentCard()?.endCardEditing()
        let properties = buttonProperties()
        
        if properties.type == .event {
            let events = properties.events.components(separatedBy: " ")
            for event in events {
                if sendMessageToElement(listener: event) == .failure {
                    break
                }
                
                sendNotificationForAction(userInfo: properties.analyticsButtonUserInfo)
            }
        } else if properties.type == .url {
            let propertiesString = properties.url
            let stringWithProtocol = prependProtocolToURLStringIfNecessary(propertiesString)
            if let url = URL(string: stringWithProtocol) {
                var userInfo: [String: Any] = [AdobeAnalyticsConstants.Keys.exitAction: stringWithProtocol]
                userInfo["action"] = AdobeAnalyticsConstants.Values.exitLink
                sendNotificationForAction(userInfo: userInfo)
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func sendNotificationForAction(userInfo: [String: Any]) {
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    private func prependProtocolToURLStringIfNecessary(_ original: String) -> String {
        if original.hasPrefix("http://") || original.hasPrefix("https://") {
            return original
        }
        
        return "http://\(original)"
    }
    
    private func checkIfJesusFilmLink(_ original: String) -> Bool {
        return original.contains("jesusfilm")
    }
    
}
