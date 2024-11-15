//
//  FirebaseInAppMessaging.swift
//  godtools
//
//  Created by Robert Eldredge on 1/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging

class FirebaseInAppMessaging: NSObject, AppMessagingInterface {
    
    static let shared: FirebaseInAppMessaging = FirebaseInAppMessaging()
    
    private let sharedInAppMessaging: InAppMessaging = InAppMessaging.inAppMessaging()
    
    private(set) weak var messagingDelegate: AppMessagingDelegate?
        
    private override init() {
        
        super.init()
    }
    
    func setMessagingDelegate(messagingDelegate: AppMessagingDelegate?) {
        
        self.messagingDelegate = messagingDelegate
    }
}

// MARK: - InAppMessagingDisplayDelegate

extension FirebaseInAppMessaging: InAppMessagingDisplayDelegate {
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage, with action: InAppMessagingAction) {
        
        if let url = action.actionURL {
            messagingDelegate?.actionTappedWithUrl(url: url)
        }
    }
        
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: FIRInAppMessagingDismissType) {
        
    }
        
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        
    }
        
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        
    }
}
