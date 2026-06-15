//
//  GetAppUIDebuggingIsEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetAppUIDebuggingIsEnabledUseCase {
    
    private let appConfig: AppConfigInterface
    
    init(appConfig: AppConfigInterface) {
        
        self.appConfig = appConfig
    }
    
    func execute() -> Bool {
        
        let isEnabled: Bool = appConfig.isDebug
        
        return isEnabled
    }
}
