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
    
    func setAppMessagingIsEnabled(launchEnvironment: inout [String: String], enabled: Bool) {
        launchEnvironment[LaunchEnvironmentKey.appMessagingIsEnabled.value] = String(enabled)
    }
    
    func setUrlDeepLink(launchEnvironment: inout [String: String], url: String) {
        launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = url
    }
}
