//
//  UITestsLaunchEnvironment.swift
//  godtools
//
//  Created by Levi Eggert on 8/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

final class UITestsLaunchEnvironment: LaunchEnvironmentReader {
    
    static let environmentName: String = "UITests"
    
    init() {
        
        super.init(
            launchEnvironment: LaunchEnvironmentReader.getProcessInfoEnvironment(),
            environmentName: UITestsLaunchEnvironment.environmentName
        )
    }
    
    func getIsUITests() -> Bool? {
        return super.getBoolValue(key: UITestsLaunchEnvironmentKey.isUITests.value)
    }
    
    func getUrlDeepLink() -> String? {
        return super.getStringValue(key: UITestsLaunchEnvironmentKey.urlDeeplink.value)
    }
}
