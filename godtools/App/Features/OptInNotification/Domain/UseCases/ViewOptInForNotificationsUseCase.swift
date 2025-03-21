//
//  ViewOptInForNotificationsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewOptInForNotificationsUseCase {
    
    init() {
        
    }
    
    func viewPublisher() -> AnyPublisher<ViewOptInForNotificationsDomainModel, Never> {
        
        let domainModel = ViewOptInForNotificationsDomainModel(
            interfaceStrings: OptInForNotificationsStringsDomainModel(
                title: "Get Tips and Encouragement",
                body: "Stay equipped for conversations. Allow notifications today.",
                enableNotificationsActionTitle: "Allow Notifications",
                enableLaterActionTitle: "Maybe Later"
            )
        )

        return Just(domainModel)
            .eraseToAnyPublisher()
    }
}
