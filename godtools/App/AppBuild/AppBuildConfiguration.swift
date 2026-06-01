//
//  AppBuildConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 8/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum AppBuildConfiguration: Sendable {
    
    case analyticsLogging
    case production
    case release
    case staging
}
