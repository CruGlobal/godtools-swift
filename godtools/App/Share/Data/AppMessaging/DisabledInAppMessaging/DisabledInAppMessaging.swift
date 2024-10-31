//
//  DisabledInAppMessaging.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/24.
//  Copyright © 2024 Cru. All rights reserved.
//

class DisabledInAppMessaging: AppMessagingInterface {
    
    private(set) weak var messagingDelegate: AppMessagingDelegate?
    
    init() {
        
    }
    
    func setMessagingDelegate(messagingDelegate: AppMessagingDelegate?) {
        
        // Won't do anything here. The purpose of this class is to provide a disabled in app messaging that does nothing. ~Levi
    }
}
