//
//  AppBuildInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol AppBuildInterface: Sendable {
    
    var configuration: AppBuildConfiguration { get }
    var environment: AppEnvironment { get }
    var isDebug: Bool { get }
    var target: BuildTarget { get }
}
