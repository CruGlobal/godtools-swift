//
//  GodToolsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct GodToolsApp: App {

    enum AppLaunchType {
        case godtools
        case uiTests
    }
    
    private static let appDeepLinkingService: DeepLinkingService = appDiContainer.core.dataLayer.getDeepLinkingService()
    private static let appDiContainer = AppDiContainer(appBuild: appBuild, appConfig: appConfig)
    private static let uiTestsLaunchEnvironment: UITestsLaunchEnvironment = UITestsLaunchEnvironment()
    
    private static let appBuild: AppBuildInterface = {
        switch appLaunchType {
        case .godtools:
            return AppBuild(
                buildConfiguration: InfoPlist().getAppBuildConfiguration()
            )
        case .uiTests:
            return UITestsBuild()
        }
    }()
    
    private static let appConfig: AppConfigInterface = {
        switch appLaunchType {
        case .godtools:
            return GodToolsAppConfig(environment: Self.appBuild.environment)
        case .uiTests:
            return UITestsAppConfig()
        }
    }()
    
    private static let parserLogger: GodToolsParserLogger = {
        appDiContainer.core.dataLayer.getGodToolsParserLogger()
    }()

    private let appFlow: AppFlow
    private let toolShortcutLinksViewModel: ToolShortcutLinksViewModel
    
    static var appLaunchType: AppLaunchType {
        let isUITests: Bool = uiTestsLaunchEnvironment.getIsUITests() ?? false
        if isUITests {
            return .uiTests
        }
        return .godtools
    }
    
    // TODO: Remove this flag once personalization is fully released. ~Levi
    static var showsPersonalization: Bool {
        return appConfig.showsPersonalization
    }
    
    @Environment(\.scenePhase) private var scenePhase
    
    @UIApplicationDelegateAdaptor private var appDelegate: GodToolsAppDelegate

    init() {
        
        let deepLinkUrl: URL?
        
        if Self.appLaunchType == .uiTests {
            
            //disable UIKit animations
            UIView.setAnimationsEnabled(false)
            
            deepLinkUrl = Self.processUITestsDeepLink()
            
            let dataLayer: AppDataLayerDependencies = Self.appDiContainer.core.dataLayer
            
            let uiTestsDataLoader = UITestsInitialDataLoader(
                resourcesCacheSync: dataLayer.getResourcesCacheSync(),
                languagesPersistence: dataLayer.getLanguagesPersistence(),
                favoritedResourcesPersistence: dataLayer.getFavoritedResourcesPersistence(),
                resourcesSHA256FileCache: dataLayer.getResourcesSHA256FileCache(),
                appLanguagesPersistence: Self.appDiContainer.feature.appLanguage.dataLayer.getAppLanguagesPersistence()
            )
            
            Task {
                do {
                    try await uiTestsDataLoader.loadData()
                }
                catch let error {
                    assertionFailure("\n UITestsInitialDataLoader failed with error: \(error.localizedDescription)")
                }
            }
        }
        else {
            
            deepLinkUrl = nil
        }

        if Self.appConfig.firebaseEnabled {
            Self.appDiContainer.core.dataLayer.getFirebaseConfiguration().configure()
        }
        
        if Self.appBuild.configuration == .analyticsLogging {
            Self.appDiContainer.core.dataLayer.getFirebaseDebugArguments().enable()
        }
        
        Self.configureDynalinkDeferredDeepLinking()
        
        appFlow = AppFlow(
            appDiContainer: Self.appDiContainer,
            appDeepLinkingService: Self.appDeepLinkingService,
            deepLinkUrl: deepLinkUrl
        )
        
        if Self.appBuild.configuration == .release {
            Task {
                await Self.parserLogger.start()
            }
        }
        
        if Self.appConfig.firebaseEnabled {
            Self.appDiContainer.core.dataLayer.getAnalytics().firebaseAnalytics.configure()
        }
        
        if Self.appBuild.configuration != .analyticsLogging {
            DisableGoogleTagManagerLogging.hideGTMLogsInfo()
            DisableGoogleTagManagerLogging.hideGTMLogsWarning()
        }
        
        toolShortcutLinksViewModel = ToolShortcutLinksViewModel(
            getCurrentAppLanguageUseCase: Self.appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolShortcutLinksUseCase: Self.appDiContainer.feature.toolShortcutLinks.domainLayer.getToolShortcutLinksUseCase()
        )
    }

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                appFlow.view
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
    
    private static func configureDynalinkDeferredDeepLinking() {
        
        guard let dynalinkClientApiKey = Self.appConfig.dynalinkClientApiKey else {
            return
        }
        
        let dataLayer: DeferredDeepLinkDataLayerDependencies = Self.appDiContainer.feature.deferredDeepLink.dataLayer
        
        dataLayer
            .getConfigureDynalink()
            .configure(clientApiKey: dynalinkClientApiKey)
    }
}

// MARK: - Expose Some Dependency for GodToolsAppDelegate and GodToolsSceneDelegate

extension GodToolsApp {
    
    static func getAppConfig() -> AppConfigInterface {
        return appConfig
    }
    
    static func getDeepLinkingService() -> DeepLinkingService {
        return appDeepLinkingService
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
            
        let dynalinkHandler: DynalinkUniversalLinkHandler = appDiContainer.feature.deferredDeepLink.dataLayer.getDynalinkUniversalLinkHandler()
        
        Task {
            
            await dynalinkHandler.handleUniversalLink(url: url)
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
            
            let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
            
            trackActionAnalyticsUseCase.trackAction(
                properties: AnalyticsProperties(
                    screenName: "",
                    siteSection: "",
                    siteSubSection: "",
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                ),
                actionName: AnalyticsConstants.ActionNames.toolOpenedShortcut,
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
    
    private static func processUITestsDeepLink() -> URL? {
        
        let uiTestsDeepLinkString: String? = Self.uiTestsLaunchEnvironment.getUrlDeepLink()

        if let uiTestsDeepLinkString = uiTestsDeepLinkString, !uiTestsDeepLinkString.isEmpty, let url = URL(string: uiTestsDeepLinkString) {
            return url
        }
        
        return nil
    }
}
