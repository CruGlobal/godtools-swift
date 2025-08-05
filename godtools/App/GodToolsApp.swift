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

    private static let appBuild: AppBuild = AppBuild(buildConfiguration: InfoPlist().getAppBuildConfiguration())
    private static let appConfig: AppConfig = AppConfig(appBuild: appBuild)
    private static let uiTestsLaunchEnvironment: UITestsLaunchEnvironment = UITestsLaunchEnvironment()
    private static let realmDatabase: RealmDatabase = RealmDatabase(databaseConfiguration: RealmDatabaseProductionConfiguration())
    private static let appDeepLinkingService: DeepLinkingService = appDiContainer.dataLayer.getDeepLinkingService()
    
    private static let appDiContainer = AppDiContainer(
        appBuild: appBuild,
        appConfig: appConfig,
        realmDatabase: realmDatabase,
        firebaseEnabled: firebaseEnabled
    )
    
    private static var isUITests: Bool {
        return uiTestsLaunchEnvironment.getIsUITests() ?? false
    }

    private static var firebaseEnabled: Bool {
        return !isUITests
    }
    
    private let appFlow: AppFlow
    private let toolShortcutLinksViewModel: ToolShortcutLinksViewModel
    
    @Environment(\.scenePhase) private var scenePhase
    
    @UIApplicationDelegateAdaptor private var appDelegate: GodToolsAppDelegate

    init() {

        appFlow = AppFlow(
            appDiContainer: Self.appDiContainer,
            appDeepLinkingService: Self.appDeepLinkingService
        )
        
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

        Self.processUITestsDeepLink()
        
        toolShortcutLinksViewModel = ToolShortcutLinksViewModel(
            getCurrentAppLanguageUseCase: Self.appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolShortcutLinksUseCase: Self.appDiContainer.feature.toolShortcutLinks.domainLayer.getViewToolShortcutLinksUseCase()
        )
    }

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                appFlow.rootView
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
                
                if let shortcutItem = GodToolsSceneDelegate.willConnectShortcutItem,
                   GodToolsApp.processShortcutItem(shortcutItem: shortcutItem) {
                   
                    GodToolsSceneDelegate.clearWillConnectShortcutItem()
                }
                else if let activityItem = GodToolsSceneDelegate.willConnectUserActivity,
                        GodToolsApp.openUrlFromUserActivity(userActivity: activityItem) {
                    
                    GodToolsSceneDelegate.clearWillConnectUserActivity()
                }

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

// MARK: - UITests Deep Link

extension GodToolsApp {
    
    private static func processUITestsDeepLink() {
        
        let uiTestsDeepLinkString: String? = Self.uiTestsLaunchEnvironment.getUrlDeepLink()

        if let uiTestsDeepLinkString = uiTestsDeepLinkString, !uiTestsDeepLinkString.isEmpty, let url = URL(string: uiTestsDeepLinkString) {
                        
            _ = Self.appDeepLinkingService.parseDeepLinkAndNotify(
                incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url))
            )
        }
    }
}
