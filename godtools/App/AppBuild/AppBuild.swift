//
//  AppBuild.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AppBuild {

    // Defined in godtools project > Info > Configurations Section.
    enum Configuration: String {
        
        case analyticsLogging = "analyticslogging"
        case staging = "staging"
        case production = "production"
        case release = "release"
    }
    
    let configuration: AppBuild.Configuration
    let environment: AppEnvironment
    let isDebug: Bool

    init(infoPlist: InfoPlist) {

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
        else if let infoPlistConfiguration = infoPlist.configuration, let buildConfiguration = AppBuild.Configuration(rawValue: infoPlistConfiguration.lowercased()) {
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
