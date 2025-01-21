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
    
    private let getGlobalActivityIsEnabled: GetGlobalActivityIsEnabledInterface
    
    init(getGlobalActivityIsEnabled: GetGlobalActivityIsEnabledInterface) {
        
        self.getGlobalActivityIsEnabled = getGlobalActivityIsEnabled
    }
    
    func getIsEnabledPublisher() -> AnyPublisher<Bool, Never> {
        
        return getGlobalActivityIsEnabled.getIsEnabledPublisher()
            .eraseToAnyPublisher()
    }
}
