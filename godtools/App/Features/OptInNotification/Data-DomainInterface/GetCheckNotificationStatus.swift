//
//  GetCheckNotificationStatus.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import UserNotifications

class GetCheckNotificationStatus:
    GetCheckNotificationStatusInterface
{

    func permissionStatusPublisher() -> AnyPublisher<
        PermissionStatusDomainModel, Never
    > {
        return Future<PermissionStatusDomainModel, Never> { promise in
            Task {
                let settings = await UNUserNotificationCenter.current()
                    .notificationSettings()

                let status: PermissionStatusDomainModel
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    status = .approved
                case .denied:
                    status = .denied
                case .notDetermined:
                    status = .undetermined
                @unknown default:
                    status = .unknown
                }
                promise(.success(status))
            }
        }
        .eraseToAnyPublisher()
    }
}
