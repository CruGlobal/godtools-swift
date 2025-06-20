//
//  GodToolsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct GodToolsApp: App {

    private static let appBuild: AppBuild = AppBuild(buildConfiguration: Self.infoPlist.getAppBuildConfiguration())
    private static let appConfig: AppConfig = AppConfig(appBuild: Self.appBuild)
    private static let appFlow: AppFlow = AppFlow(appDiContainer: Self.appDiContainer, appDeepLinkingService: Self.appDeepLinkingService)
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
    
    @Environment(\.scenePhase) private var scenePhase
    
    @UIApplicationDelegateAdaptor private var appDelegate: GodToolsAppDelegate
    
    @State private var toolShortcutLinks: ToolShortcutLinksView?

    init() {

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
                Self.appFlow.rootView
            }
            .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { (phase: ScenePhase) in

            switch phase {
            case .background:
                reloadShortcutItems(application: Self.getUIApplication())
            case .inactive:
                break
            case .active:
                reloadShortcutItems(application: Self.getUIApplication())
            @unknown default:
                break
            }
        }
    }
    
    static func getUIApplication() -> UIApplication {
        return UIApplication.shared
    }
    
    static func getAppConfig() -> AppConfig {
        return appConfig
    }
    
    static func getAppDiContainer() -> AppDiContainer {
        return appDiContainer
    }
    
    static func getAppDeepLinkingService() -> DeepLinkingService {
        return appDeepLinkingService
    }
}

// MARK: - Reload Shortcut Items

extension GodToolsApp {
    
    private func reloadShortcutItems(application: UIApplication) {
                
        let viewModel = ToolShortcutLinksViewModel(
            getCurrentAppLanguageUseCase: Self.appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolShortcutLinksUseCase: Self.appDiContainer.feature.toolShortcutLinks.domainLayer.getViewToolShortcutLinksUseCase()
        )
            
        let view = ToolShortcutLinksView(
            application: application,
            viewModel: viewModel
        )
        
        toolShortcutLinks = view
    }
}
