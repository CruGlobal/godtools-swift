//
//  LaunchEnvironmentReader.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LaunchEnvironmentReader {
    
    private let launchEnvironment: [String: String]
    
    init(launchEnvironment: [String: String]) {
        
        self.launchEnvironment = launchEnvironment
    }
    
    static func createFromProcessInfo() -> LaunchEnvironmentReader {
        return LaunchEnvironmentReader(launchEnvironment: ProcessInfo.processInfo.environment)
    }
    
    func getAppMessagingIsEnabled() -> Bool? {
        
        guard let stringBool = launchEnvironment[LaunchEnvironmentKey.appMessagingIsEnabled.value] else {
            return nil
        }
        
        return Bool(stringBool)
    }
    
    func getUrlDeepLink() -> String? {
        return launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value]
    }
}
