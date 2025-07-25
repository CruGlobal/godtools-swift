//
//  LaunchEnvironmentWriter.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LaunchEnvironmentWriter {
        
    init() {
        
    }
    
    func setFirebaseEnabled(launchEnvironment: inout [String: String], enabled: Bool) {
        launchEnvironment[LaunchEnvironmentKey.firebaseEnabled.value] = String(enabled)
    }
    
    func setIsUITests(launchEnvironment: inout [String: String], isUITests: Bool) {
        launchEnvironment[LaunchEnvironmentKey.isUITests.value] = String(isUITests)
    }
    
    func setUrlDeepLink(launchEnvironment: inout [String: String], url: String) {
        launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = url
    }
}
