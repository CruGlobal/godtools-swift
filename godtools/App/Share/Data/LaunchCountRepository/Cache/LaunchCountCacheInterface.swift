//
//  LaunchCountCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

protocol LaunchCountCacheInterface: Sendable {

    @MainActor func getLaunchCountChangedPublisher() -> AnyPublisher<Int, Never>
    func getLaunchCount() -> Int
    func storeLaunchCount(count: Int) async throws
}
