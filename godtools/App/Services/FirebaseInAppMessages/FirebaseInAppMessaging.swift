//
//  FirebaseInAppMessaging.swift
//  godtools
//
//  Created by Robert Eldredge on 1/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging

class FirebaseInAppMessaging: NSObject, FirebaseInAppMessagingType {
    
    private let sharedInAppMessaging: InAppMessaging = InAppMessaging.inAppMessaging()
    
    override init() {
        
        super.init()
        
        sharedInAppMessaging.delegate = self
    }
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {

    }
        
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: FIRInAppMessagingDismissType) {
        
    }
        
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        
    }
        
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        
    }
    
    func triggerInAppMessage(eventId: String) {
        
        sharedInAppMessaging.triggerEvent(eventId)
    }
}
