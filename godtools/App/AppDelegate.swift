//
//  AppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import AppsFlyerLib
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let appWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        
    private lazy var appDeepLinkingService: DeepLinkingService = {
       
        return appDiContainer.dataLayer.getDeepLinkingService()
    }()
    
    private lazy var appDiContainer: AppDiContainer = {
        
        AppDiContainer()
    }()
    
    private lazy var appFlow: AppFlow = {
        
        AppFlow(appDiContainer: appDiContainer, window: appWindow, appDeepLinkingService: appDeepLinkingService)
    }()
    
    var window: UIWindow?
    
    static func setWindowBackgroundColorForStatusBarColor(color: UIColor) {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.backgroundColor = color
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
        let appConfig: AppConfig = appDiContainer.dataLayer.getAppConfig()
        
        if appConfig.build == .analyticsLogging {
            appDiContainer.getFirebaseDebugArguments().enable()
        }
                
        appDiContainer.getFirebaseConfiguration().configure()
        
        if appConfig.build == .release {
                        
            GodToolsParserLogger.shared.start()
        }
                
        appDiContainer.dataLayer.getSharedAppsFlyer().configure(appsFlyerConfiguration: appConfig.appsFlyerConfiguration, deepLinkDelegate: self)
        
        appDiContainer.analytics.firebaseAnalytics.configure()
        
        appDiContainer.analytics.appsFlyerAnalytics.configure()
        
        appDiContainer.getGoogleAdwordsAnalytics().recordAdwordsConversion()
        
        appDiContainer.analytics.snowplowAnalytics.configure()
                
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // window
        let window: UIWindow = appWindow
        window.backgroundColor = UIColor.white
        window.rootViewController = appFlow.rootController
        window.makeKeyAndVisible()
        self.window = window
        
        application.registerForRemoteNotifications()
        
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
        
        AppEvents.activateApp()
        
        appDiContainer.analytics.appsFlyerAnalytics.trackAppLaunch()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
}

// MARK: - Shortcut Items

extension AppDelegate {
    
    private func reloadShortcutItems(application: UIApplication) {
        
        application.shortcutItems = appDiContainer.domainLayer.getShortcutItemsUseCase().getShortcutItems()
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
                
        guard let shortcutItemType = ShortcutItemType.shortcutItemType(shortcutItem: shortcutItem) else {
            completionHandler(false)
            return
        }
        
        let successfullyHandledQuickAction: Bool
        
        switch shortcutItemType {
            
        case .tool:
            
            appDiContainer.analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: "", actionName: AnalyticsConstants.ActionNames.toolOpenedShortcut, siteSection: "", siteSubSection: "", url: nil, data: [
                AnalyticsConstants.Keys.toolOpenedShortcutCountKey: 1
            ]))
            
            if let tractUrl = ToolShortcutItem.getTractUrl(shortcutItem: shortcutItem) {
                successfullyHandledQuickAction = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: tractUrl)))
            }
            else {
                successfullyHandledQuickAction = false
            }
        }
        
        completionHandler(successfullyHandledQuickAction)
    }
}

// MARK: - Open Url (Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.)

// Return Value: true if the delegate successfully handled the request or false if the attempt to open the URL resource failed.

extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        appDiContainer.dataLayer.getSharedAppsFlyer().handleOpenUrl(url: url, options: options)
        
        let deepLinkedHandled: Bool = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        let facebookHandled: Bool = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        if deepLinkedHandled {
            return true
        }
        else if facebookHandled {
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
