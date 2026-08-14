//
//  TestsDiContainer.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsDiContainer {

    private let appDiContainer: AppDiContainer

    init(
        testsAppConfig: TestsAppConfig,
        appBuild: AppBuildInterface = TestsBuild()
    ) {

        appDiContainer = AppDiContainer(
            appBuild: appBuild,
            appConfig: testsAppConfig,
            firebaseAnalytics: DisabledFirebaseAnalytics()
        )
    }

    var core: AppCoreDiContainer {
        return appDiContainer.core
    }

    var feature: AppFeatureDiContainer {
        return appDiContainer.feature
    }
}
