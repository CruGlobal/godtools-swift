//
//  CheckNotificationStatusUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import UserNotifications

class CheckNotificationStatusUseCase {
   
    private let checkNotificationStatus: GetCheckNotificationStatusInterface

    init(checkNotificationStatus: GetCheckNotificationStatusInterface) {
        self.checkNotificationStatus = checkNotificationStatus
    }

    func getPermissionStatusPublisher() -> AnyPublisher<PermissionStatusDomainModel, Never> {
        
        return checkNotificationStatus.permissionStatusPublisher()
            .eraseToAnyPublisher()
    }
}
