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

                var userInfo: [String: Any] = [AdobeAnalyticsConstants.Keys.newProfessingBelieverAction: 1]
                let relay = AnalyticsRelay.shared
                switch (relay.screenName, relay.viewListener) {
                case ("kgp-us-5", "followup-form"):
                    userInfo["action"] = AdobeAnalyticsConstants.Values.kgpUSGospelPresented
                    sendNotificationForAction(userInfo: userInfo)
                case ("kgp-5", "followup-form"):
                    userInfo["action"] = AdobeAnalyticsConstants.Values.kgpNewProfessingBeliever
                    sendNotificationForAction(userInfo: userInfo)
                case ("fourlaws-6", "followup-form"):
                    userInfo["action"] = AdobeAnalyticsConstants.Values.fourLawsNewProfessingBeliever
                    sendNotificationForAction(userInfo: userInfo)
                case ("thefour-5", "followup-form"):
                    userInfo["action"] = AdobeAnalyticsConstants.Values.theFourNewProfessingBeliever
                    sendNotificationForAction(userInfo: userInfo)
                default:
                    print("no notifications")
                }
            }
        } else if properties.type == .url {
            let propertiesString = properties.url
            let openInJFPApp = checkIfJesusFilmLink(propertiesString)
            let stringWithProtocol = prependProtocolToURLStringIfNecessary(propertiesString)
            if let url = URL(string: stringWithProtocol) {
                
                var userInfo: [String: Any] = [AdobeAnalyticsConstants.Keys.exitAction: stringWithProtocol]
                userInfo["action"] = AdobeAnalyticsConstants.Values.exitLink
                sendNotificationForAction(userInfo: userInfo)
                if openInJFPApp {
                    launchApp(decodedURL: "gtTestCustomUrlScheme://"/*propertiesString*/)
                } else {
                    UIApplication.shared.openURL(url)
                }
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
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        let alertPrompt = UIAlertController(title: "Open in App", message: "You're going to open the app \"Jesus Film Project\"", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertPrompt, animated: true, completion: nil)
        
        
    }
    
}
