//
//  CheckNotificationStatusUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UserNotifications

final class CheckNotificationStatusUseCase {
   
    private let getNotificationStatus: GetNotificationStatus
    
    init(getNotificationStatus: GetNotificationStatus) {
        
        self.getNotificationStatus = getNotificationStatus
    }
    
    func execute() async throws -> PermissionStatusDomainModel {
       
        return try await getNotificationStatus.getStatus()
    }
}
