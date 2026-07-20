//
//  GetAppUIDebuggingIsEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetAppUIDebuggingIsEnabledUseCase {
    
    private let appBuild: AppBuildInterface
    
    init(appBuild: AppBuildInterface) {
        
        self.appBuild = appBuild
    }
    
    func execute() -> Bool {
        
        let isEnabled: Bool = appBuild.isDebug
        
        return isEnabled
    }
}
