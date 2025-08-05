//
//  LaunchEnvironmentWriter.swift
//  godtools
//
//  Created by Levi Eggert on 8/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LaunchEnvironmentWriter {
    
    let environmentName: String
    
    init(environmentName: String) {
    
        self.environmentName = environmentName
    }
    
    func getKeyValue(key: String) -> String {
        return LaunchEnvironmentKey(environmentName: environmentName, key: key).value
    }
    
    func writeStringValue(launchEnvironment: inout [String: String], key: String, value: String) {
        launchEnvironment[getKeyValue(key: key)] = value
    }
    
    func writeBoolValue(launchEnvironment: inout [String: String], key: String, value: Bool) {
        launchEnvironment[getKeyValue(key: key)] = String(value)
    }
}
