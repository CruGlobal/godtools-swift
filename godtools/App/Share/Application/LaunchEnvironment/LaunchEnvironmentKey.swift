//
//  LaunchEnvironmentKey.swift
//  godtools
//
//  Created by Levi Eggert on 8/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LaunchEnvironmentKey {
    
    let value: String
    
    init(environmentName: String, key: String) {
        value = "\(environmentName).\(key)"
    }
}
