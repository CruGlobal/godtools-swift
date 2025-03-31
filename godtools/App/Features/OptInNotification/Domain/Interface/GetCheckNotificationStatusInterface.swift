//
//  GetCheckNotificationStatusInterface.swift
//  godtools
//
//  Created by Jason Bennett on 3/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation

protocol GetCheckNotificationStatusInterface {

    func permissionStatusPublisher() -> AnyPublisher<String, Never>
}
