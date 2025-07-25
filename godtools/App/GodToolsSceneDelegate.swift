//
//  GodToolsSceneDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import FacebookCore
import FirebaseDynamicLinks

class GodToolsSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private static var window: UIWindow?
    private static var windowBackgroundColor: UIColor = UIColor.white
    
    private(set) static var willConnectShortcutItem: UIApplicationShortcutItem?
    private(set) static var willConnectUserActivity: NSUserActivity?
            
    static func getWindow() -> UIWindow? {
        return Self.window
    }
    
    static func setWindowBackgroundColorForStatusBarColor(color: UIColor) {
        Self.windowBackgroundColor = color
        Self.window?.backgroundColor = color
    }
    
    static func clearWillConnectShortcutItem() {
        Self.willConnectShortcutItem = nil
    }
    
    static func clearWillConnectUserActivity() {
        Self.willConnectUserActivity = nil
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Keeping a static reference so these can be handled in GodToolsApp scenePhase active. Needed when launching app from terminated state. ~Levi
        Self.willConnectShortcutItem = connectionOptions.shortcutItem
        Self.willConnectUserActivity = connectionOptions.userActivities.first
        
        if let windowScene = scene as? UIWindowScene {
            Self.window = windowScene.keyWindow
            Self.setWindowBackgroundColorForStatusBarColor(color: Self.windowBackgroundColor)
        }
    }
}

// MARK: - UserActivity (Tells the delegate to handle the specified Handoff-related activity.)

extension GodToolsSceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        _ = GodToolsApp.openUrlFromUserActivity(userActivity: userActivity)
    }
}

// MARK: - Shortcut Items (Tells the delegate that the user selected a Home screen quick action for your app, except when you’ve intercepted the interaction in a launch method.)

// Completion: The block you call after your quick action implementation completes, returning true or false depending on the success or failure of your implementation code.

extension GodToolsSceneDelegate {
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let didHandleShortcutItem: Bool = GodToolsApp.processShortcutItem(
            shortcutItem: shortcutItem
        )
        
        completionHandler(didHandleShortcutItem)
    }
}

// MARK: - Asks the delegate to open one or more URLs.

extension GodToolsSceneDelegate {
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            
        guard let url = URLContexts.first?.url else {
            return
        }
        
        // Facebook
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
