//
//  GetRequestNotificationPermission.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import UserNotifications

class GetRequestNotificationPermission: GetRequestNotificationPermissionInterface {

    func requestPermissionPublisher() -> AnyPublisher<Bool, Never> {
    
        return Future<Bool, Never> { promise in
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted: Bool, _) in

                promise(.success(granted))
            }
        }.flatMap { granted in

            Just(granted)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
