//
//  TestsBuild.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

struct TestsBuild: AppBuildInterface {
    
    let configuration: AppBuildConfiguration = .production
    let environment: AppEnvironment = .production
    let isDebug: Bool = true
    let target: BuildTarget = .tests
}
