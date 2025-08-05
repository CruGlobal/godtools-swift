//
//  UITestsLaunchEnvironmentKey.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum UITestsLaunchEnvironmentKey: String {
    
    var value: String {
        return rawValue
    }
    
    case isUITests
    case urlDeeplink
}
