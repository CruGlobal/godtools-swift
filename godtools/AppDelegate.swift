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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var flowController: BaseFlowController?
    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    let loginClient = TheKeyOAuthClient.shared
    fileprivate let kClientID = "5337397229970887848"
    fileprivate let kRedirectURI = "https://godtoolsapp.com/auth"
    fileprivate let kAppAuthExampleAuthStateKey = "authState"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        GodToolsAnaltyics.setup()
        
        #if DEBUG
            print(NSHomeDirectory())
        #endif
        
        _ = FollowUpsManager().syncCachedFollowUps()
        
        self.startFlowController()
        
        self.initalizeAppState().ensure {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    // MARK: - Flow controllers setup
    
    func startFlowController() {
        self.window = UIWindow(frame : UIScreen.main.bounds)
        self.flowController = PlatformFlowController(window: self.window!)
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: App state initialization/refresh
    
    private func initalizeAppState() -> Promise<DownloadedResources> {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: GTConstants.kFirstLaunchKey)
        let deviceLocaleHasBeenDownloaded = UserDefaults.standard.bool(forKey: GTConstants.kDownloadDeviceLocaleKey)
        
        let languagesManager = LanguagesManager()
        
        if isFirstLaunch {
            FirstLaunchInitializer().initializeAppState()
        }
        
        let p = firstly {
            languagesManager.loadFromRemote()
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
        
        return p
    }
    
    private func resetStateIfUITesting() {
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
    }
}

