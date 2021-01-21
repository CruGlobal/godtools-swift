//
//  Firebase.swift
//  godtools
//
//  Created by Robert Eldredge on 1/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging

class Firebase: NSObject, FirebaseType {
    override init() {
        
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
        InAppMessaging.inAppMessaging().triggerEvent(eventId);
    }
}
