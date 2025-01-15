//
//  GetGlobalActivityEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetGlobalActivityEnabledUseCase {
    
    init() {
        
    }
    
    func getEnabledPublisher() -> AnyPublisher<Bool, Never> {
        return Just(false)
            .eraseToAnyPublisher()
    }
}
