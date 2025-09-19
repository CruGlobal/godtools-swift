//
//  LaunchEnvironmentReader.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LaunchEnvironmentReader {
    
    let launchEnvironment: [String: String]
    let environmentName: String
    
    init(launchEnvironment: [String: String], environmentName: String) {
        
        self.launchEnvironment = launchEnvironment
        self.environmentName = environmentName
    }
    
    static func createFromProcessInfo(environmentName: String) -> LaunchEnvironmentReader {
        return LaunchEnvironmentReader(
            launchEnvironment: getProcessInfoEnvironment(),
            environmentName: environmentName
        )
    }
    
    static func getProcessInfoEnvironment() -> [String: String] {
        return ProcessInfo.processInfo.environment
    }
    
    func getKeyValue(key: String) -> String {
        return LaunchEnvironmentKey(environmentName: environmentName, key: key).value
    }
    
    func getStringValue(key: String) -> String? {
        return launchEnvironment[getKeyValue(key: key)]
    }
    
    func getBoolValue(key: String) -> Bool? {
        
        guard let stringBool = launchEnvironment[getKeyValue(key: key)] else {
            return nil
        }
        
        return Bool(stringBool)
    }
}
