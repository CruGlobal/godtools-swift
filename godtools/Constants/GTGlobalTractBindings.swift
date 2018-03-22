//
//  GTGlobalTractBindings.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTGlobalTractBindings: NSObject {
    
    enum Bindings:String {
        case followUp = "followup:send"
    }
    
    static func listen(listener: String, element: BaseTractElement) -> EventResult {
        switch listener {
        case Bindings.followUp.rawValue:
            let manager = FollowUpsManager()
            guard let form = BaseTractElement.getFormForElement(element) else {
                return .viewNotFound
            }
            
            if(!form.validateForm()) {
                return .failure
            }
            
            let params = form.getFormData()
            
            _ = manager.createSubscriber(params: params)?.then(execute: { (_) -> Void in
                
                guard let resource = form.tractConfigurations?.resource else { return }
                let code = resource.code
                
                var userInfo: [String: Any] = [AdobeAnalyticsConstants.Keys.emailSignUpAction: 1]

                switch code {
                case "kgp":
                    userInfo["action"] = AdobeAnalyticsConstants.Values.kgpEmailSignUp
                case "fourlaws":
                    userInfo["action"] = AdobeAnalyticsConstants.Values.fourLawsEmailSignUp
                default :
                    print("resource.code is: \(code)\n")
                    print("resource.name is: \(resource.name)\n")
                    break
                }
                NotificationCenter.default.post(name: .actionTrackNotification,
                                                object: nil,
                                                userInfo: userInfo)
            })
            
        default: break

        }
        return .success
    }

}
