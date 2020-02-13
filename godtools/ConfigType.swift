//
//  ConfigType.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ConfigType {
    
    var isDebug: Bool { get }
    var appleAppId: String { get }
    var appVersion: String { get }
    var bundleVersion: String { get }
    var versionLabel: String { get }
    var appsFlyerDevKey: String { get }
}
