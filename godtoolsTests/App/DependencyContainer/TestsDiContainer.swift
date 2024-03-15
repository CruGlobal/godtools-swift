//
//  TestsDiContainer.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsDiContainer: AppDiContainer {
    
    init(realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()) {
        
        let appBuild = AppBuild(buildConfiguration: nil)
        
        let appConfig = AppConfig(appBuild: appBuild)
                
        super.init(
            appBuild: appBuild,
            appConfig: appConfig,
            infoPlist: InfoPlist(),
            realmDatabase: realmDatabase
        )
    }
}
