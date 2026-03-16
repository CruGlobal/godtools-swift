//
//  OptInNotificationStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct OptInNotificationStringsDomainModel: Sendable {
    
    let title: String
    let body: String
    let allowNotificationsActionTitle: String
    let notificationSettingsActionTitle: String
    let maybeLaterActionTitle: String
    
    static var emptyValue: OptInNotificationStringsDomainModel {
        return OptInNotificationStringsDomainModel(title: "", body: "", allowNotificationsActionTitle: "", notificationSettingsActionTitle: "", maybeLaterActionTitle: "")
    }
}
