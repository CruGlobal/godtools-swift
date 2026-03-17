//
//  RequestNotificationPermissionUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

final class RequestNotificationPermissionUseCase {

    init() {
        
    }
    
    func execute() -> AnyPublisher<Bool, Error> {
    
        return AnyPublisher() {
            return try await self.requestAuthorization()
        }
    }
    
    private func requestAuthorization() async throws -> Bool {
        
        return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
}
