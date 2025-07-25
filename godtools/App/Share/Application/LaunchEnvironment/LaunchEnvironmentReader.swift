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
    
    func getFirebaseEnabled() -> Bool? {
        
        guard let stringBool = launchEnvironment[LaunchEnvironmentKey.firebaseEnabled.value] else {
            return nil
        }
        
        return Bool(stringBool)
    }
    
    func getIsUITests() -> Bool? {
        
        guard let stringBool = launchEnvironment[LaunchEnvironmentKey.isUITests.value] else {
            return nil
        }
        
        return Bool(stringBool)
    }
    
    func getUrlDeepLink() -> String? {
        return launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value]
    }
}
