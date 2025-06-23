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
        
    static func getWindow() -> UIWindow? {
        return Self.window
    }
    
    static func setWindowBackgroundColorForStatusBarColor(color: UIColor) {
        Self.window?.backgroundColor = color
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let userActivity = connectionOptions.userActivities.first {
            _ = GodToolsApp.openUrlFromUserActivity(userActivity: userActivity)
        }
        
        if let windowScene = scene as? UIWindowScene {
            Self.window = windowScene.keyWindow
        }
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
