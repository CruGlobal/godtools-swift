//
//  GodToolsAppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import SocialAuthentication

class GodToolsAppDelegate: NSObject, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
             
        print("\n GodToolsAppDelegate didFinishLaunchingWithOptions launchOptions")
        
        let application: UIApplication = UIApplication.shared
        
        ConfigureFacebookOnAppLaunch.configure(
            application: application,
            launchOptions: launchOptions,
            configuration: GodToolsApp.getAppConfig().getFacebookConfiguration()
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
}

// MARK: - Scene

extension GodToolsAppDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        print("\n GodToolsAppDelegate: configurationForConnecting connectingSceneSession")
        
        if options.userActivities.count > 1 {
            print("  has user activities")
        }
        
        if options.shortcutItem != nil {
            print("  has shortcut item")
        }
        
        let sceneConfig = UISceneConfiguration(
            name: "main",
            sessionRole: .windowApplication
        )
        
        sceneConfig.delegateClass = GodToolsSceneDelegate.self
        
        return sceneConfig
    }
}

// MARK: - Remote Notifications

extension GodToolsAppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       
        print("\n GodToolsAppDelegate: didRegisterForRemoteNotificationsWithDeviceToken")
        
        FirebaseMessaging.registerDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       
        print("\n GodToolsAppDelegate: didReceiveRemoteNotification")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("\n GodToolsAppDelegate: didReceiveRemoteNotification")
    }
}
