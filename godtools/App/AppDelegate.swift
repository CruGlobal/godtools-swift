//
//  AppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    private let appDiContainer: AppDiContainer = AppDiContainer()
    private var appFlow: AppFlow?
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        appDiContainer.config.logConfiguration()
        
        if appDiContainer.config.build == .analyticsLogging {
            appDiContainer.getFirebaseDebugArguments().enable()
        }
                
        appDiContainer.firebaseConfiguration.configure()
        
        let appFlow = AppFlow(appDiContainer: appDiContainer)
        
        self.appFlow = appFlow
        
        appDiContainer.appsFlyer.configure()
                
        appDiContainer.analytics.adobeAnalytics.configure()
        appDiContainer.analytics.adobeAnalytics.collectLifecycleData()
        
        appDiContainer.analytics.firebaseAnalytics.configure()
        
        appDiContainer.analytics.appsFlyerAnalytics.configure(adobeAnalytics: appDiContainer.analytics.adobeAnalytics)
        
        appDiContainer.googleAdwordsAnalytics.recordAdwordsConversion()
        
        appDiContainer.analytics.snowplowAnalytics.configure(adobeAnalytics: appDiContainer.analytics.adobeAnalytics)
                
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.rootViewController = appFlow.rootController
        window.makeKeyAndVisible()
        self.window = window
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        appFlow?.applicationWillResignActive(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        appFlow?.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        appFlow?.applicationDidBecomeActive(application)
        appDiContainer.analytics.appsFlyerAnalytics.trackAppLaunch()
        //on app launch, sync Adobe Analytics auth state
        appDiContainer.analytics.adobeAnalytics.fetchAttributesThenSyncIds()
        appDiContainer.analytics.firebaseAnalytics.fetchAttributesThenSetUserId()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        appDiContainer.deepLinkingService.parseDeepLink(incomingDeepLink: .url(url: url))
        
        appDiContainer.appsFlyer.handleOpenUrl(url: url, options: options)
        
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
                
        guard let shortcutItemType = ShortcutItemType.shortcutItemType(shortcutItem: shortcutItem) else {
            return
        }
        
        switch shortcutItemType {
            
        case .tool:
            
            appDiContainer.analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: nil, actionName: AnalyticsConstants.Values.toolOpenedShortcut, siteSection: "", siteSubSection: "", url: nil, data: [
                AnalyticsConstants.ActionNames.toolOpenedShortcutCountKey: 1
            ]))
            
            if let tractUrl = ToolShortcutItem.getTractUrl(shortcutItem: shortcutItem) {
                appDiContainer.deepLinkingService.parseDeepLink(incomingDeepLink: .url(url: tractUrl))
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        appDiContainer.appsFlyer.continueUserActivity(userActivity: userActivity)
        
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        if url.containsDeepLinkHost(deepLinkHost: .godToolsApp), url.path.contains("auth") {
            if let theKeyUserAuthentication = appDiContainer.userAuthentication as? TheKeyUserAuthentication {
                return theKeyUserAuthentication.canResumeAuthorizationFlow(url: url)
            }
        }
                
        appDiContainer.deepLinkingService.parseDeepLink(incomingDeepLink: .url(url: url))
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        appDiContainer.appsFlyer.registerUninstall(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        appDiContainer.appsFlyer.handlePushNotification(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        appDiContainer.appsFlyer.handlePushNotification(userInfo: userInfo)
    }
}
