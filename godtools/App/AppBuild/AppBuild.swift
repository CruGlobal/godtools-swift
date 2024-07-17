//
//  AppBuild.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AppBuild {

    let configuration: AppBuildConfiguration
    let environment: AppEnvironment
    let isDebug: Bool

    init(buildConfiguration: AppBuildConfiguration?) {

        // RELEASE and DEBUG flags need to be set under Build Settings > Other Swift Flags.  Add -DDEBUG for debug builds and -DRELEASE for release builds.
       
        #if RELEASE
            isDebug = false
        #elseif DEBUG
            isDebug = true
        #else
            isDebug = false
            assertionFailure("In ( Build Settings > Other Swift Flags ) set either -DDEBUG or -DRELEASE for each scheme.")
        #endif

        if !isDebug {
            configuration = .release
        }
        else if let buildConfiguration = buildConfiguration {
            configuration =  buildConfiguration
        }
        else if isDebug {
            configuration = .staging
        }
        else {
            configuration =  .release
        }
        
        switch configuration {
            
        case .analyticsLogging:
            environment = .production
        case .staging:
            environment = .staging
        case .production:
            environment = .production
        case .release:
            environment = .production
        }
    }
    
    var isTestsTarget: Bool {
        return NSClassFromString("XCTest") != nil
    }
}
