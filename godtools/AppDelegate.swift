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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var flowController: BaseFlowController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self, Answers.self])
        GodToolsAnaltyics.setup()
        
        #if DEBUG
            print(NSHomeDirectory())
        #endif
        
        self.initalizeAppState(launchOptions: launchOptions)
            .always {
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
    
    func startFlowController(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        self.window = UIWindow(frame : UIScreen.main.bounds)
        self.flowController = PlatformFlowController(window: self.window!, launchOptions: launchOptions)
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: App state initialization/refresh
    
    private func initalizeAppState(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Promise<Any> {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: GTConstants.kFirstLaunchKey)
        let deviceLocaleHasBeenDownloaded = UserDefaults.standard.bool(forKey: GTConstants.kDownloadDeviceLocaleKey)
        
        let languagesManager = LanguagesManager()
        
        if isFirstLaunch {
            FirstLaunchInitializer().initializeAppState()
        } else {
            self.startFlowController(launchOptions: launchOptions)
        }
        
        return languagesManager.loadFromRemote().then { (languages) -> Promise<DownloadedResources> in
            return DownloadedResourceManager().loadFromRemote()
            }.then { (resources) -> Promise<DownloadedResources> in
                if !isFirstLaunch, !deviceLocaleHasBeenDownloaded {
                    self.flowController?.showDeviceLocaleDownloadedAndSwitchPrompt()
                } else if isFirstLaunch {
                    languagesManager.setPrimaryLanguageForInitialDeviceLanguageDownload()
                    TranslationZipImporter().catchupMissedDownloads()
                } else {
                    TranslationZipImporter().catchupMissedDownloads()
                }
                
                return Promise(value: resources)
            }.catch(execute: { (error) in
                if isFirstLaunch {
                    self.flowController?.showDeviceLocaleDownloadFailedAlert()
                }
            }).always {
                // if on first launch, earlier the app waited for the initial downloads to work, so the flow controller did not no start.
                // so now, start the flow controller.
                if isFirstLaunch {
                    self.startFlowController(launchOptions: launchOptions)
                }
        }
    }
}

