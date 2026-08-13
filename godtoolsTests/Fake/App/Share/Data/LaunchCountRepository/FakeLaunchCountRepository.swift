//
//  FakeLaunchCountRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

final class FakeLaunchCountRepository: LaunchCountRepositoryInterface {
    
    private let launchCount: Int
    
    init(launchCount: Int) {
        
        self.launchCount = launchCount
    }
    
    func getLaunchCountChangedPublisher() -> AnyPublisher<Int, Never> {
        
        return Just(launchCount)
            .eraseToAnyPublisher()
    }
    
    func getLaunchCount() -> Int {
        return launchCount
    }
    
    func storeLaunchCount(count: Int) async throws {
        
    }
}
