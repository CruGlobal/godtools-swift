//
//  AppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Combine
import AppsFlyerLib
import SocialAuthentication
import FacebookCore
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
           
    private static var getShortcutItemsCancellable: AnyCancellable?
    
    private lazy var appBuild: AppBuild = {
        AppBuild(buildConfiguration: infoPlist.getAppBuildConfiguration())
    }()
    
    private lazy var appConfig: AppConfig = {
        AppConfig(appBuild: appBuild)
    }()
    
    private lazy var infoPlist: InfoPlist = {
        InfoPlist()
    }()
    
    private lazy var realmDatabase: RealmDatabase = {
        RealmDatabase(databaseConfiguration: RealmDatabaseProductionConfiguration())
    }()
    
    private lazy var appDeepLinkingService: DeepLinkingService = {
        return appDiContainer.dataLayer.getDeepLinkingService()
    }()
    
    private lazy var appDiContainer: AppDiContainer = {
        AppDiContainer(appBuild: appBuild, appConfig: appConfig, infoPlist: infoPlist, realmDatabase: realmDatabase)
    }()
    
    private lazy var appFlow: AppFlow = {
        AppFlow(appDiContainer: appDiContainer, appDeepLinkingService: appDeepLinkingService)
    }()
    
    var window: UIWindow?
    
    static func getWindow() -> UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }
    
    static func setWindowBackgroundColorForStatusBarColor(color: UIColor) {
        AppDelegate.getWindow()?.backgroundColor = color
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                    
        DisableGoogleTagManagerLogging.disable()
        
        let appConfig: AppConfig = appDiContainer.dataLayer.getAppConfig()
        
        if appBuild.configuration == .analyticsLogging {
            appDiContainer.getFirebaseDebugArguments().enable()
        }
                
        appDiContainer.getFirebaseConfiguration().configure()
        
        if appBuild.configuration == .release {
            GodToolsParserLogger.shared.start()
        }
                
        appDiContainer.dataLayer.getSharedAppsFlyer().configure(configuration: appConfig.getAppsFlyerConfiguration(), deepLinkDelegate: self)
        
        appDiContainer.dataLayer.getAnalytics().firebaseAnalytics.configure()
        
        appDiContainer.dataLayer.getAnalytics().appsFlyerAnalytics.configure()
        
        appDiContainer.getGoogleAdwordsAnalytics().recordAdwordsConversion()
        
        ConfigureFacebookOnAppLaunch.configure(
            application: application,
            launchOptions: launchOptions,
            configuration: appConfig.getFacebookConfiguration()
        )
               
        // window
        let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.rootViewController = appFlow.getInitialView()
        window.makeKeyAndVisible()
        self.window = window
        
        application.registerForRemoteNotifications()
        
        let uiTestsDeepLinkString: String? = ProcessInfo.processInfo.environment[LaunchEnvironmentKey.urlDeeplink.value]
                
        if let uiTestsDeepLinkString = uiTestsDeepLinkString, !uiTestsDeepLinkString.isEmpty,
           let url = URL(string: uiTestsDeepLinkString) {
            
            _ = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        reloadShortcutItems(application: application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        reloadShortcutItems(application: application)
                
        appDiContainer.dataLayer.getAnalytics().appsFlyerAnalytics.trackAppLaunch()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
}

// MARK: - Shortcut Items

extension AppDelegate {
    
    private func reloadShortcutItems(application: UIApplication) {
        
        let viewModel = ToolShortcutLinksViewModel(
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolShortcutLinksUseCase: appDiContainer.feature.appShortcutItems.domainLayer.getToolShortcutLinksUseCase()
        )
            
        let view = ToolShortcutLinksView(
            application: application,
            viewModel: viewModel
        )     
    }
}

// MARK: - Remote Notifications

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       
        appDiContainer.dataLayer.getSharedAppsFlyer().registerUninstall(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
       
        appDiContainer.dataLayer.getSharedAppsFlyer().handlePushNotification(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        appDiContainer.dataLayer.getSharedAppsFlyer().handlePushNotification(userInfo: userInfo)
    }
}

// MARK: - Home Screen Action (Tells the delegate that the user selected a Home screen quick action for your app, except when you’ve intercepted the interaction in a launch method.)

// Completion: The block you call after your quick action implementation completes, returning true or false depending on the success or failure of your implementation code.

extension AppDelegate {
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
               
        let successfullyHandledQuickAction: Bool
        
        if let toolDeepLinkUrlString = ToolShortcutLinksView.getToolDeepLinkUrl(shortcutItem: shortcutItem),
           let toolDeepLinkUrl = URL(string: toolDeepLinkUrlString) {
            
            let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
            
            trackActionAnalyticsUseCase.trackAction(
                screenName: "",
                actionName: AnalyticsConstants.ActionNames.toolOpenedShortcut,
                siteSection: "",
                siteSubSection: "",
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

        completionHandler(successfullyHandledQuickAction)
    }
}

// MARK: - Open Url (Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.)

// Return Value: true if the delegate successfully handled the request or false if the attempt to open the URL resource failed.

extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        appDiContainer.dataLayer.getSharedAppsFlyer().handleOpenUrl(url: url, options: options)
        
        if let firebaseDynamicLinkUrl = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)?.url {
            _ = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: firebaseDynamicLinkUrl)))
            return true
        }
        
        let facebookHandled: Bool = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        let deepLinkedHandled: Bool = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if facebookHandled || deepLinkedHandled {
            return true
        }
        
        return false
    }
}

// MARK: - Continue User Activity (The app calls this method when it receives data associated with a user activity.)

// Return Value: true to indicate that your app handled the activity or false to let iOS know that your app didn't handle the activity.

extension AppDelegate {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        appDiContainer.dataLayer.getSharedAppsFlyer().continueUserActivity(userActivity: userActivity)
        
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        let firebaseDynamicLinkHandled: Bool = DynamicLinks.dynamicLinks().handleUniversalLink(url) { [weak self] (dynamicLink: DynamicLink?, error: Error?) in
            
            guard let firebaseDynamicLinkUrl = dynamicLink?.url else {
                return
            }
            
            DispatchQueue.main.async {
                _ = self?.appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: firebaseDynamicLinkUrl)))
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
}

// MARK: - AppsFlyer DeepLinkDelegate

extension AppDelegate: DeepLinkDelegate {
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        
        guard let data = result.deepLink?.clickEvent else {
            return
        }
        
        _ = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .appsFlyer(data: data))
    }
}
