//
//  GetRequestNotificationPermissionInterface.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation

protocol GetRequestNotificationPermissionInterface {

    func permissionGrantedPublisher() -> AnyPublisher<Bool, Never>
}
