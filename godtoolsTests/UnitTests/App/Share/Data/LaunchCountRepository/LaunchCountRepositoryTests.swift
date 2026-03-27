//
//  LaunchCountRepositoryTests.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine

struct LaunchCountRepositoryTests {
    
    // TODO: Complete tests.  Need to simulator app did become active and enter background life cycle.  Interface needed. ~Levi
}

extension LaunchCountRepositoryTests {
    
    private func getLaunchCountRepository() -> LaunchCountRepository {
        
        let launchCountRepository = LaunchCountRepository.shared
        
        launchCountRepository.resetLaunchCount()
        
        return launchCountRepository
    }
}
