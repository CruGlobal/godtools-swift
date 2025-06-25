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
                             
        ConfigureFacebookOnAppLaunch.configure(
            application: application,
            launchOptions: launchOptions,
            configuration: GodToolsApp.getAppConfig().getFacebookConfiguration()
        )
        
        registerForRemoteNotifications(application: application)
        
        return true
    }
}

// MARK: - Scene

extension GodToolsAppDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
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
               
        FirebaseMessaging.registerDeviceToken(deviceToken: deviceToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension GodToolsAppDelegate: UNUserNotificationCenterDelegate {
    
    private func registerForRemoteNotifications(application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
    }
    
    // Asks the delegate how to handle a notification that arrived while the app was running in the foreground.
    
    // completionHandler (The block to execute with the presentation option for the notification. Always execute this block at some point during your implementation of this method. Use the options parameter to specify how you want the system to alert the user, if at all. This block has no return value and takes the following parameter:) (https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter(_:willpresent:withcompletionhandler:))
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo: [AnyHashable: Any] = notification.request.content.userInfo
        
        FirebaseMessaging.didReceiveMessage(userInfo: userInfo)
        
        completionHandler([.badge, .sound])
    }
    
    // Asks the delegate to process the user’s response to a delivered notification.
    
    // completionHandler (The block to execute when you have finished processing the user’s response. You must execute this block at some point after processing the user’s response to let the system know that you are done. The block has no return value or parameters.) (https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter(_:didreceive:withcompletionhandler:))
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        
        FirebaseMessaging.didReceiveMessage(userInfo: userInfo)
        
        completionHandler()
    }
}
