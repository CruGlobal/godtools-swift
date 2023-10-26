//
//  TestsGetLaunchCountRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetLaunchCountRepository: GetLaunchCountRepositoryInterface {
    
    let launchCount: Int
    
    init(launchCount: Int) {
        
        self.launchCount = launchCount
    }
    
    func getCountPublisher() -> AnyPublisher<Int, Never> {
        
        return Just(launchCount)
            .eraseToAnyPublisher()
    }
}
