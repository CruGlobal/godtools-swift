//
//  LaunchCountRepository.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class LaunchCountRepository: LaunchCountRepositoryInterface {

    private let cache: LaunchCountCacheInterface

    init(cache: LaunchCountCacheInterface) {

        self.cache = cache
    }

    @MainActor func getLaunchCountChangedPublisher() -> AnyPublisher<Int, Never> {

        return cache.getLaunchCountChangedPublisher()
    }

    func getLaunchCount() -> Int {

        return cache.getLaunchCount()
    }
    
    func storeLaunchCount(count: Int) async throws {
        
        try await cache.storeLaunchCount(count: count)
    }
}
