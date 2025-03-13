//
//  ViewOptInNotificationsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation

//here
// Job: retrieving and preparing the necessary data for the notifications sheet view
// Specifically, we need to translate the interface strings
class ViewOptInNotificationsUseCase {

    // get repository

    // init repo
    init() {

    }
    // provide publisher data stream for view layer to react to
    func viewPublisher() -> AnyPublisher<
        ViewOptInNotificationsDomainModel, Never
    > {

        let domainModel = ViewOptInNotificationsDomainModel(
            interfaceStrings: OptInNotificationsStringsDomainModel(
                title: "Get Tips and Encouragement",
                body:
                    "Stay equipped for conversations. Allow notifications today.",
                enableNotificationsActionTitle: "Allow Notifications",
                enableLaterActionTitle: "Maybe Later"
            ),
            lastPrompted: "SAMPLE_STRING"
        )

        return Just(domainModel)
            .eraseToAnyPublisher()
    }
}
