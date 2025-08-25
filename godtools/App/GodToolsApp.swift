//
//  GodToolsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct GodToolsApp: App {

    private enum AppLaunchType {
        case godtools
        case uiTests
    }
    
    private static let appDeepLinkingService: DeepLinkingService = appDiContainer.dataLayer.getDeepLinkingService()
    private static let appDiContainer = AppDiContainer(appConfig: appConfig)
    private static let uiTestsLaunchEnvironment: UITestsLaunchEnvironment = UITestsLaunchEnvironment()
    
    private static let appConfig: AppConfigInterface = {
        switch appLaunchType {
        case .godtools:
            return GodToolsAppConfig()
        case .uiTests:
            return UITestsAppConfig()
        }
    }()
    
    private static var appLaunchType: AppLaunchType {
        let isUITests: Bool = uiTestsLaunchEnvironment.getIsUITests() ?? false
        if isUITests {
            return .uiTests
        }
        return .godtools
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
        
        if Self.appConfig.buildConfig == .analyticsLogging {
            Self.appDiContainer.getFirebaseDebugArguments().enable()
        }

        if Self.appConfig.firebaseEnabled {
            Self.appDiContainer.getFirebaseConfiguration().configure()
        }

        if Self.appConfig.buildConfig == .release {
            GodToolsParserLogger.shared.start()
        }
        
        if Self.appConfig.firebaseEnabled {
            Self.appDiContainer.dataLayer.getAnalytics().firebaseAnalytics.configure()
        }

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
    
    static func getAppConfig() -> AppConfigInterface {
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

        let deepLinkHandled: Bool = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))

        if deepLinkHandled {
            return true
        }

        return false
    }
    
    static func openUrl(url: URL) -> Bool {
                
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
