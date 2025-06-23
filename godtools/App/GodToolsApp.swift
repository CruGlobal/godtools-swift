//
//  GodToolsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import FirebaseDynamicLinks

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
    
    private let toolShortcutLinksViewModel: ToolShortcutLinksViewModel
    
    @Environment(\.scenePhase) private var scenePhase
    
    @UIApplicationDelegateAdaptor private var appDelegate: GodToolsAppDelegate

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
        
        toolShortcutLinksViewModel = ToolShortcutLinksViewModel(
            getCurrentAppLanguageUseCase: Self.appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolShortcutLinksUseCase: Self.appDiContainer.feature.toolShortcutLinks.domainLayer.getViewToolShortcutLinksUseCase()
        )
    }

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                Self.appFlow.rootView
            }
            .ignoresSafeArea()
            .onOpenURL { (url: URL) in
                _ = Self.openUrl(url: url)
            }
        }
        .onChange(of: scenePhase) { (phase: ScenePhase) in

            let application = UIApplication.shared
            
            switch phase {
            case .background:
                reloadShortcutItems(application: application)
            case .inactive:
                break
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Expose Some Dependency for GodToolsAppDelegate and GodToolsSceneDelegate

extension GodToolsApp {
    
    static func getAppConfig() -> AppConfig {
        return appConfig
    }
}

// MARK: - Reload Shortcut Items

extension GodToolsApp {
    
    private func reloadShortcutItems(application: UIApplication) {
                
        application.shortcutItems = toolShortcutLinksViewModel.shortcutLinks
    }
}

// MARK: - Open URL

extension GodToolsApp {
    
    static func openUrlFromUserActivity(userActivity: NSUserActivity) -> Bool {
        
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }

        guard let url = userActivity.webpageURL else {
            return false
        }

        let firebaseDynamicLinkHandled: Bool = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink: DynamicLink?, error: Error?) in

            guard let firebaseDynamicLinkUrl = dynamicLink?.url else {
                return
            }

            DispatchQueue.main.async {
                _ = Self.appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: firebaseDynamicLinkUrl)))
            }
        }

        if firebaseDynamicLinkHandled {
            return true
        }

        let deepLinkHandled: Bool = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))

        if deepLinkHandled {
            return true
        }

        return false
    }
    
    static func openUrl(url: URL) -> Bool {
        
        if let firebaseDynamicLinkUrl = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)?.url {
            _ = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: firebaseDynamicLinkUrl)))
            return true
        }
        
        // TODO: Test facebook login. ~Levi
        
        //let facebookHandled: Bool = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        let deepLinkedHandled: Bool = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if deepLinkedHandled {
            return true
        }
        
        return false
    }
}

// MARK: - Shortcut Items

extension GodToolsApp {
    
    static func processShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        let successfullyHandledQuickAction: Bool
        
        if let toolDeepLinkUrlString = ToolShortcutLinksViewModel.getToolDeepLinkUrl(shortcutItem: shortcutItem), let toolDeepLinkUrl = URL(string: toolDeepLinkUrlString) {
            
            let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
            
            trackActionAnalyticsUseCase.trackAction(
                screenName: "",
                actionName: AnalyticsConstants.ActionNames.toolOpenedShortcut,
                siteSection: "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                contentLanguageSecondary: nil,
                url: nil,
                data: [
                    AnalyticsConstants.Keys.toolOpenedShortcutCountKey: 1
                ]
            )
            
            successfullyHandledQuickAction = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: toolDeepLinkUrl)))
        }
        else {
            
            successfullyHandledQuickAction = false
        }

        return successfullyHandledQuickAction
    }
}
