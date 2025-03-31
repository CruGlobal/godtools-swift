//
//  RequestNotificationPermissionUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import UserNotifications

class RequestNotificationPermissionUseCase {

    private let requestNotificationPermission:
        GetRequestNotificationPermissionInterface

    init(
        requestNotificationPermission:
            GetRequestNotificationPermissionInterface
    ) {
        self.requestNotificationPermission =
            requestNotificationPermission
    }

    func getPermissionGrantedPublisher() -> AnyPublisher<Bool, Never> {
        return requestNotificationPermission.permissionGrantedPublisher()
            .eraseToAnyPublisher()
    }

}
