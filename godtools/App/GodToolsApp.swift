//
//  GodToolsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct GodToolsApp: App {
       
    private static let appBuild: AppBuild = AppBuild(buildConfiguration: Self.infoPlist.getAppBuildConfiguration())
    private static let appConfig: AppConfig = AppConfig(appBuild: Self.appBuild)
    private static let infoPlist: InfoPlist = InfoPlist()
    private static let launchEnvironmentReader: LaunchEnvironmentReader = LaunchEnvironmentReader.createFromProcessInfo()
    private static let realmDatabase: RealmDatabase = RealmDatabase(databaseConfiguration: RealmDatabaseProductionConfiguration())
    
    private static let appDiContainer = AppDiContainer(
        appBuild: appBuild,
        appConfig: appConfig,
        infoPlist: infoPlist,
        realmDatabase: realmDatabase,
        firebaseEnabled: firebaseEnabled
    )
    
    private static let appDeepLinkingService: DeepLinkingService = Self.appDiContainer.dataLayer.getDeepLinkingService()
    
    private static var firebaseEnabled: Bool {
        return launchEnvironmentReader.getFirebaseEnabled() ?? true
    }
    
    init() {
        print("GodToolsApp.init()")
                
        if Self.appBuild.configuration == .analyticsLogging {
            Self.appDiContainer.getFirebaseDebugArguments().enable()
        }
            
        if Self.firebaseEnabled {
            Self.appDiContainer.getFirebaseConfiguration().configure()
        }
        
        if Self.appBuild.configuration == .release {
            GodToolsParserLogger.shared.start()
        }
                        
        Self.appDiContainer.dataLayer.getAnalytics().firebaseAnalytics.configure()
            
        // TODO: How to implement? ~Levi
        /*
        ConfigureFacebookOnAppLaunch.configure(
            application: application,
            launchOptions: launchOptions,
            configuration: appConfig.getFacebookConfiguration()
        )
        
        application.registerForRemoteNotifications()*/
        
        let uiTestsDeepLinkString: String? = Self.launchEnvironmentReader.getUrlDeepLink()
                
        if let uiTestsDeepLinkString = uiTestsDeepLinkString, !uiTestsDeepLinkString.isEmpty, let url = URL(string: uiTestsDeepLinkString) {
            _ = Self.appDeepLinkingService.parseDeepLinkAndNotify(
                incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url))
            )
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                    
            }
            .background(
                AppFlow(
                    appDiContainer: Self.appDiContainer,
                    appDeepLinkingService: Self.appDeepLinkingService
                )
            )
        }
    }
}
