//
//  GetLaunchCountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLaunchCountUseCase {
    
    private let launchCountRepository: LaunchCountRepository
    
    init(launchCountRepository: LaunchCountRepository) {
        
        self.launchCountRepository = launchCountRepository
    }
    
    func getCountPublisher() -> AnyPublisher<Int, Never> {
        
        return launchCountRepository.getLaunchCountPublisher()
            .eraseToAnyPublisher()
    }
}
