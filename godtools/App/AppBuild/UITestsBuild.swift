//
//  UITestsBuild.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct UITestsBuild: AppBuildInterface {
    
    let configuration: AppBuildConfiguration = .production
    let environment: AppEnvironment = .production
    let isDebug: Bool = true
    let isTestsTarget: Bool = false
    let isUiTestsTarget: Bool = true
}
