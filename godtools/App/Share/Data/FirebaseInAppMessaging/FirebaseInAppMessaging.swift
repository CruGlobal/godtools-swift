//
//  FirebaseInAppMessaging.swift
//  godtools
//
//  Created by Robert Eldredge on 1/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging

protocol FirebaseInAppMessagingDelegate: AnyObject {
    
    func firebaseInAppMessageActionTappedWithUrl(url: URL)
}

class FirebaseInAppMessaging: NSObject {
    
    static let shared: FirebaseInAppMessaging = FirebaseInAppMessaging()
    
    private let sharedInAppMessaging: InAppMessaging = InAppMessaging.inAppMessaging()
    
    private weak var delegate: FirebaseInAppMessagingDelegate?
    
    private override init() {
        
        super.init()
    }
    
    func setDelegate(delegate: FirebaseInAppMessagingDelegate?) {
        
        if self.delegate != nil && delegate != nil {
            assertionFailure("\nWARNING: Attempting to set delegate that has already been set on \(String(describing: self.delegate)).  Is this intended?\n")
        }
        
        sharedInAppMessaging.delegate = self
        self.delegate = delegate
    }
    
    func triggerInAppMessage(eventName: String) {
        
        sharedInAppMessaging.triggerEvent(eventName)
    }
}

// MARK: - InAppMessagingDisplayDelegate

extension FirebaseInAppMessaging: InAppMessagingDisplayDelegate {
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage, with action: InAppMessagingAction) {
        
        if let url = action.actionURL {
            delegate?.firebaseInAppMessageActionTappedWithUrl(url: url)
        }
    }
        
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: FIRInAppMessagingDismissType) {
        
    }
        
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        
    }
        
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        
    }
}
