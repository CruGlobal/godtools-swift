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
    
    private let appBuild: AppBuild
    
    init(appBuild: AppBuild) {
        
        self.appBuild = appBuild
    }
    
    func getIsEnabledPublisher() -> AnyPublisher<Bool, Never> {
        
        let isEnabled: Bool = appBuild.isDebug
        
        return Just(isEnabled)
            .eraseToAnyPublisher()
    }
}
