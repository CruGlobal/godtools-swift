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
    
    init(
        testsAppConfig: TestsAppConfig,
        appBuild: AppBuildInterface = TestsBuild()
    ) {
   
        super.init(appBuild: appBuild, appConfig: testsAppConfig)
    }
}
