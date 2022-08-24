//
//  AppBuild.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// Defined in godtools project > Info > Configurations Section.

enum AppBuild: String {
    
    case analyticsLogging = "analyticslogging"
    case staging = "staging"
    case production = "production"
    case release = "release"
}
