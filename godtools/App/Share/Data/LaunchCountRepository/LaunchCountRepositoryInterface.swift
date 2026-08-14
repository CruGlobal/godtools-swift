//
//  LaunchCountRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol LaunchCountRepositoryInterface: Sendable {
    
    @MainActor func getLaunchCountChangedPublisher() -> AnyPublisher<Int, Never>
    
    func getLaunchCount() -> Int
    func storeLaunchCount(count: Int) async throws
}
