//
//  RequestNotificationPermissionUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UserNotifications

final class RequestNotificationPermissionUseCase {

    init() {
        
    }
    
    func execute() async throws -> Bool {
    
        return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
}
