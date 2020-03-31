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
import PromiseKit
import RealmSwift
import AppAuth
import TheKeyOAuthSwift
import FBSDKCoreKit

enum ShortcutItemType: String {
    case tool = "ToolAction"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    private let appDiContainer: AppDiContainer = AppDiContainer()
    
    var window: UIWindow?
    var flowController: BaseFlowController?
    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    let loginClient = TheKeyOAuthClient.shared
    fileprivate let kClientID = "5337397229970887848"
    fileprivate let kRedirectURI = "https://godtoolsapp.com/auth"
    fileprivate let kAppAuthExampleAuthStateKey = "authState"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        appDiContainer.config.logConfiguration()
        
        appDiContainer.firebaseConfiguration.configure()
        
        appDiContainer.adobeAnalytics.configure()
        
        appDiContainer.appsFlyer.configure(adobeAnalytics: appDiContainer.adobeAnalytics)
        
        resetStateIfUITesting()
        
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
        
        Fabric.with([Crashlytics.self, Answers.self])

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        #if DEBUG
            print(NSHomeDirectory())
        #endif
        
        _ = FollowUpsManager().syncCachedFollowUps()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        flowController = BaseFlowController(appDiContainer: appDiContainer)
        window.rootViewController = flowController?.navigationController
        window.makeKeyAndVisible()
        self.window = window
        
        initalizeAppState()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        application.shortcutItems = shortCutItems()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        flowController?.applicationDidBecomeActive(application)
        appDiContainer.appsFlyer.trackAppLaunch()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    // MARK: App state initialization/refresh
    private func initalizeAppState() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: GTConstants.kFirstLaunchKey)
        let deviceLocaleHasBeenDownloaded = UserDefaults.standard.bool(forKey: GTConstants.kDownloadDeviceLocaleKey)
        
        let languagesManager = LanguagesManager()
        
        if isFirstLaunch {
            FirstLaunchInitializer().initializeAppState()
        }
        
        let p = firstly {
            LanguagesManager().loadFromRemote()
        }.then {  (_) -> Promise<DownloadedResources> in
            if isFirstLaunch {
                languagesManager.setPrimaryLanguageForInitialDeviceLanguageDownload()
            }
            return DownloadedResourceManager().loadFromRemote()
        }.then { (resources) -> Promise<DownloadedResources> in
            if !isFirstLaunch, !deviceLocaleHasBeenDownloaded {
                self.flowController?.showDeviceLocaleDownloadedAndSwitchPrompt()
            } else {
                TranslationZipImporter().catchupMissedDownloads()
            }
            return .value(resources)
        }

        p.catch { (error) in
            if isFirstLaunch {
                self.flowController?.showDeviceLocaleDownloadFailedAlert()
            }
        }
    }
    
    private func resetStateIfUITesting() {
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func shortCutItems() -> [UIApplicationShortcutItem] {
        let toolsManager = ToolsManager.shared
        let languagesManager = LanguagesManager()
        
        var shortcuts: [UIApplicationShortcutItem] = []
        
        for resource in toolsManager.resources {
            let localizedTitle = resource.localizedName(language: languagesManager.loadPrimaryLanguageFromDisk())
            let shortcutItem = UIApplicationShortcutItem(type: ShortcutItemType.tool.rawValue,
                                                         localizedTitle: localizedTitle,
                                                         localizedSubtitle: nil,
                                                         icon: nil,
                                                         userInfo: resource.quickActionUserInfo)
            shortcuts.append(shortcutItem)
        }
        
        return shortcuts
    }
    
    /// Called when the user selects a Home screen quick action
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type == ShortcutItemType.tool.rawValue, let urlString = shortcutItem.userInfo?[TractURL] as? String, let url = URL(string: urlString)  {
            processForDeepLinking(from: url, shouldDisplayLoadingScreen: false)
        }
    }
}

