//
//  AppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import AppsFlyerLib

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
        
        appDiContainer.analytics.adobeAnalytics.configure()
        appDiContainer.analytics.adobeAnalytics.collectLifecycleData()
        
        appDiContainer.analytics.firebaseAnalytics.configure()
        
        appDiContainer.analytics.appsFlyer.configure(adobeAnalytics: appDiContainer.analytics.adobeAnalytics)
        
        appDiContainer.googleAdwordsAnalytics.recordAdwordsConversion()
        
        appDiContainer.analytics.snowplowAnalytics.configure(adobeAnalytics: appDiContainer.analytics.adobeAnalytics)
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
           
        appFlow = AppFlow(appDiContainer: appDiContainer)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.rootViewController = appFlow?.rootController
        window.makeKeyAndVisible()
        self.window = window
        
        application.registerForRemoteNotifications()
        
        AppsFlyerLib.shared().appsFlyerDevKey = "QdbVaVHi9bHRchUTWtoaij"
        AppsFlyerLib.shared().appleAppID = "id542773210"
        AppsFlyerLib.shared().delegate = self
        
        #if DEBUG
            AppsFlyerLib.shared().isDebug = true
        #else
            AppsFlyerLib.shared().isDebug = false
        #endif
                        
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
        appDiContainer.analytics.appsFlyer.trackAppLaunch()
        //on app launch, sync Adobe Analytics auth state
        appDiContainer.analytics.adobeAnalytics.fetchAttributesThenSyncIds()
        appDiContainer.analytics.firebaseAnalytics.fetchAttributesThenSetUserId()
        
        AppsFlyerLib.shared().start()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        appDiContainer.analytics.appsFlyer.handleOpenUrl(url: url, options: options)
        
        AppsFlyerLib.shared().handleOpen(url, options: options)
        
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
                
        guard let shortcutItemType = ShortcutItemType.shortcutItemType(shortcutItem: shortcutItem) else {
            return
        }
        
        switch shortcutItemType {
            
        case .tool:
            
            appDiContainer.analytics.trackActionAnalytics.trackAction(
                screenName: nil,
                actionName: AnalyticsConstants.Values.toolOpenedShortcut,
                data: [
                    AnalyticsConstants.ActionNames.toolOpenedShortcutCountKey: 1
                ]
            )
            
            if let tractUrl = ToolShortcutItem.getTractUrl(shortcutItem: shortcutItem) {
                appDiContainer.deepLinkingService.processDeepLink(url: tractUrl)
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        if let host = url.host, host.contains("godtoolsapp") {
            if let theKeyUserAuthentication = appDiContainer.userAuthentication as? TheKeyUserAuthentication {
                return theKeyUserAuthentication.canResumeAuthorizationFlow(url: url)
            }
        } else {
            appDiContainer.deepLinkingService.processDeepLink(url: url)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        appDiContainer.analytics.appsFlyer.registerUninstall(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deep Link: \(error)")
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        let resourceName: String
        
        if let is_first_launch = data["is_first_launch"] as? Bool,
            is_first_launch {
            print("First Launch")
        } else {
            print("Not First Launch")
        }
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            resourceName = deepLinkValue
        } else if let linkParam = data["link"] as? String {
            guard let url = URLComponents(string: linkParam) else {
                print("Could not extract query params from link")
                return
            }
            guard let deepLinkValue = url.queryItems?.first(where: { $0.name == "deep_link_value" })?.value  else {
                print("Could not extract query params from link")
                return
            }
            resourceName = deepLinkValue
        } else {
            print("Could not extract query params from link")
            return
        }
        
        appFlow?.navigateToTool(resourceName: resourceName)
    }
    
    func onConversionDataFail(_ error: Error) {
        assertionFailure("AppsFlyer Error on Open Deferred Deep Link: \(error)")
    }
}
