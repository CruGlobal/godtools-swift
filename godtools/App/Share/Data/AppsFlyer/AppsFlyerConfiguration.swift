//
//  AppsFlyerConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppsFlyerConfiguration {
    
    let appleAppId: String
    let appsFlyerDevKey: String
    let shouldUseUninstallSandbox: Bool
    
    init(appleAppId: String, appsFlyerDevKey: String, shouldUseUninstallSandbox: Bool) {
        
        self.appleAppId = appleAppId
        self.appsFlyerDevKey = appsFlyerDevKey
        self.shouldUseUninstallSandbox = shouldUseUninstallSandbox
    }
}
