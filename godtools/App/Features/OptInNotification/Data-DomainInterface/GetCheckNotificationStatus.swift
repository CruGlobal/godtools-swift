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

    func permissionStatusPublisher() -> AnyPublisher<String, Never> {
        return Future<String, Never> { promise in
            Task {
                let settings = await UNUserNotificationCenter.current()
                    .notificationSettings()

                let status: String
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    status = "Approved"
                case .denied:
                    status = "Denied"
                case .notDetermined:
                    status = "Undetermined"
                @unknown default:
                    status = "Unknown"
                }
                promise(.success(status))
            }
        }
        .eraseToAnyPublisher()
    }
}
