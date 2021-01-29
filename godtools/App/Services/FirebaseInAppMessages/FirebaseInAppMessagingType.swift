//
//  FirebaseInAppMessagingType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging

protocol FirebaseInAppMessagingType: InAppMessagingDisplayDelegate {
    func triggerInAppMessage(eventId: String)
}
