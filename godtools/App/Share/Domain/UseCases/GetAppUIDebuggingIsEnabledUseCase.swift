//
//  GetAppUIDebuggingIsEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppUIDebuggingIsEnabledUseCase {
    
    private let appConfig: AppConfigInterface
    
    init(appConfig: AppConfigInterface) {
        
        self.appConfig = appConfig
    }
    
    func getIsEnabledPublisher() -> AnyPublisher<Bool, Never> {
        
        let isEnabled: Bool = appConfig.isDebug
        
        return Just(isEnabled)
            .eraseToAnyPublisher()
    }
}
