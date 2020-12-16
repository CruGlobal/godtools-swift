//
//  AppDelegate.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AppAuth
import TheKeyOAuthSwift
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    private let appDiContainer: AppDiContainer = AppDiContainer()
    private var appFlow: AppFlow?
    
    var window: UIWindow?
    
    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    let loginClient = TheKeyOAuthClient.shared
    fileprivate let kClientID = "5337397229970887848"
    fileprivate let kRedirectURI = "https://godtoolsapp.com/auth"
    fileprivate let kAppAuthExampleAuthStateKey = "authState"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           
        // Login Client
        loginClient.configure(baseCasURL: URL(string: "https://thekey.me/cas")!,
                              clientID: kClientID,
                              redirectURI: URL(string: kRedirectURI)!)
        
        let hasRegisteredEmail = UserDefaults.standard.bool(forKey: GTConstants.kUserEmailIsRegistered)
        if !hasRegisteredEmail && loginClient.isAuthenticated() {
            loginClient.fetchAttributes() { (attributes, _) in
                let signupManager = EmailSignUpManager()
                signupManager.signUpUserForEmailRegistration(attributes: attributes)
            }
        }
        
        appDiContainer.config.logConfiguration()
        
        appDiContainer.firebaseConfiguration.configure()
        
        appDiContainer.analytics.adobeAnalytics.configure()
        appDiContainer.analytics.adobeAnalytics.collectLifecycleData()
        
        appDiContainer.analytics.firebaseAnalytics.configure()
        
        appDiContainer.analytics.appsFlyer.configure(adobeAnalytics: appDiContainer.analytics.adobeAnalytics)
        
        appDiContainer.googleAdwordsAnalytics.recordAdwordsConversion()
        
        appDiContainer.analytics.snowplowAnalytics.configure(adobeAnalytics: appDiContainer.analytics.adobeAnalytics)
        
        Fabric.with([Crashlytics.self, Answers.self])

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
           
        appFlow = AppFlow(appDiContainer: appDiContainer)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.rootViewController = appFlow?.rootController
        window.makeKeyAndVisible()
        self.window = window
        
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
        
        GAI.sharedInstance().dispatchInterval = 1
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        appDiContainer.analytics.appsFlyer.handleOpenUrl(url: url, options: options)
        
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
                
        guard let shortcutItemType = ShortcutItemType.shortcutItemType(shortcutItem: shortcutItem) else {
            return
        }
        
        switch shortcutItemType {
            
        case .tool:
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
            if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeAuthorizationFlow(with: url) {
                
                self.currentAuthorizationFlow = nil
                return true
            }
        } else {
            
            appDiContainer.deepLinkingService.processDeepLink(url: url)
        }
        
        return true
    }
}
