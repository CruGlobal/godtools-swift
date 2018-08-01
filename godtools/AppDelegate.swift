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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        resetStateIfUITesting()
        
        loginClient.configure(baseCasURL: URL(string: "https://thekey.me/cas")!,
                              clientID: kClientID,
                              redirectURI: URL(string: kRedirectURI)!)
        
        if loginClient.isAuthenticated() {
            loginClient.fetchAttributes() { (attributes, _) in
                if let userAtts = attributes, let masterPersonId = userAtts["grMasterPersonId"] {
                        if let storedPersonId = UserDefaults.standard.value(forKey: "grMasterPersonId") as? String {
                            // Don't need to resend
                            let userAttributes = AppDelegate.processAttributes(dict: userAtts)
                            AppDelegate.sendPostWithUserEmail(attributes: userAttributes)
                            print("else userAttributes ><><>", userAttributes)
                        } else  {
                            UserDefaults.standard.set(masterPersonId, forKey: "grMasterPersonId")
                            let userAttributes = AppDelegate.processAttributes(dict: userAtts)
                            AppDelegate.sendPostWithUserEmail(attributes: userAttributes)
                            print("else userAttributes ><><>", userAttributes)
                        }
                    }
                
                /*
                ["lastName": "Doe", "ssoGuid": "49E1F2F9-55CC-6C10-58FF-B9B46CA79579", "email": "test@test.com", "firstName": "John", "grMasterPersonId": "6017a717-251c-434f-aa2f-e4279328fa59"]
                */
                debugPrint("User's Attributes >> ", attributes ?? "nothing")
                
            }
        }
        
        Fabric.with([Crashlytics.self, Answers.self])
        GodToolsAnaltyics.setup()
        
        #if DEBUG
            print(NSHomeDirectory())
        #endif
        
        _ = FollowUpsManager().syncCachedFollowUps()
        
        self.startFlowController()
        
        self.initalizeAppState()
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
    
   static func processAttributes(dict: [String: String]) -> [String: String] {
        var userDict = [String: String]()
        if let lastName = dict["lastName"] {
            userDict["last_name"] = lastName
        }
        if let firstName = dict["firstName"] {
            userDict["first_name"] = firstName
        }
        if let email = dict["email"] {
            userDict["email_address"] = email
            userDict["id"] = "3fb6022c-5ef9-458c-928a-0380c4a0e57b"
        }
        return userDict
    }
    
   static func sendPostWithUserEmail(attributes: [String: String]) {
        Alamofire.request("https://campaign-forms.cru.org/forms",
                     method: HTTPMethod.post,
                     parameters: attributes)
            .validate({ (request, response, data) -> Request.ValidationResult in
                if response.statusCode / 100 != 2 {
                    return .failure(DataManagerError.StatusCodeError(response.statusCode))
                }
                print(response)
                if let data = data {
                    let dataString = String(data: data, encoding: .utf8)
                    print(dataString ?? "no data sent to https://campaign-forms.cru.org/forms")
                }
                
                return .success
            })
    
    }
    
    // MARK: - Flow controllers setup
    
    func startFlowController() {
        self.window = UIWindow(frame : UIScreen.main.bounds)
        self.flowController = PlatformFlowController(window: self.window!)
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: App state initialization/refresh
    
    private func initalizeAppState() -> Promise<Any> {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: GTConstants.kFirstLaunchKey)
        let deviceLocaleHasBeenDownloaded = UserDefaults.standard.bool(forKey: GTConstants.kDownloadDeviceLocaleKey)
        
        let languagesManager = LanguagesManager()
        
        if isFirstLaunch {
            FirstLaunchInitializer().initializeAppState()
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
            })
    }
    
    private func resetStateIfUITesting() {
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
    }
}

