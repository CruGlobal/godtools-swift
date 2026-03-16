//
//  GetNotificationStatus.swift
//  godtools
//
//  Created by Levi Eggert on 3/7/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

final class GetNotificationStatus {
    
    init() {
        
    }
    
    func getStatus() async throws -> PermissionStatusDomainModel {
        
        let settings = await UNUserNotificationCenter.current()
            .notificationSettings()
        
        switch settings.authorizationStatus {
        
        case .authorized, .provisional, .ephemeral:
            return .approved
        
        case .denied:
            return .denied
        
        case .notDetermined:
            return .undetermined
        
        @unknown default:
            return .unknown
        }
    }
    
    func getStatusPublisher() -> AnyPublisher<PermissionStatusDomainModel, Error> {
        return AnyPublisher() {
            return try await self.getStatus()
        }
    }
}
