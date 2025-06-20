//
//  GodToolsAppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import FacebookCore
import FirebaseDynamicLinks
import SocialAuthentication

class GodToolsAppDelegate: NSObject, UIApplicationDelegate {
    
    private let appDeepLinkingService: DeepLinkingService = GodToolsApp.getAppDeepLinkingService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
             
        print("\n GodToolsAppDelegate didFinishLaunchingWithOptions launchOptions")
        
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
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       
        print("\n GodToolsAppDelegate: didReceiveRemoteNotification")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("\n GodToolsAppDelegate: didReceiveRemoteNotification")
    }
}

// MARK: - Open Url (Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.)

// Return Value: true if the delegate successfully handled the request or false if the attempt to open the URL resource failed.

extension GodToolsAppDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
                
        // TODO: Needs testing. ~Levi
        
        print("\n GodToolsAppDelegate: open url options")
        
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
