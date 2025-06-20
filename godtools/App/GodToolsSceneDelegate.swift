//
//  GodToolsSceneDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks

class GodToolsSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private static var window: UIWindow?
    
    private let appDiContainer: AppDiContainer = GodToolsApp.getAppDiContainer()
    private let appDeepLinkingService: DeepLinkingService = GodToolsApp.getAppDeepLinkingService()
    
    static func getWindow() -> UIWindow? {
        return Self.window
    }
    
    static func setWindowBackgroundColorForStatusBarColor(color: UIColor) {
        Self.window?.backgroundColor = color
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            Self.window = windowScene.keyWindow
        }
    }
}

// MARK: - Continue User Activity (Use this method to update the specified scene with the data from the provided activity object. UIKit calls this method on your app’s main thread only after it receives all of the data for an activity object, which might originate from a different device).

extension GodToolsSceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        // TODO: Needs testing. ~Levi
        
        print("\n GodToolsSceneDelegate continue userActivity \(userActivity)")
        
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return
        }
        
        guard let url = userActivity.webpageURL else {
            return
        }
        
        let firebaseDynamicLinkHandled: Bool = DynamicLinks.dynamicLinks().handleUniversalLink(url) { [weak self] (dynamicLink: DynamicLink?, error: Error?) in
            
            guard let firebaseDynamicLinkUrl = dynamicLink?.url else {
                return
            }
            
            DispatchQueue.main.async {
                _ = self?.appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: firebaseDynamicLinkUrl)))
            }
        }
        
        if firebaseDynamicLinkHandled {
            return
        }
        
        let deepLinkHandled: Bool = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if deepLinkHandled {
            return
        }
        
        return
    }
}

// MARK: - Home Screen Action (Tells the delegate that the user selected a Home screen quick action for your app, except when you’ve intercepted the interaction in a launch method.)

// Completion: The block you call after your quick action implementation completes, returning true or false depending on the success or failure of your implementation code.

extension GodToolsSceneDelegate {
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let didHandleShortcutItem: Bool = didProcessShortcutItem(
            shortcutItem: shortcutItem
        )
        
        completionHandler(didHandleShortcutItem)
    }
}

// MARK: - Process Shortcut Item

extension GodToolsSceneDelegate {
    
    private func didProcessShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        let successfullyHandledQuickAction: Bool
        
        if let toolDeepLinkUrlString = ToolShortcutLinksView.getToolDeepLinkUrl(shortcutItem: shortcutItem), let toolDeepLinkUrl = URL(string: toolDeepLinkUrlString) {
            
            let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
            
            trackActionAnalyticsUseCase.trackAction(
                screenName: "",
                actionName: AnalyticsConstants.ActionNames.toolOpenedShortcut,
                siteSection: "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                contentLanguageSecondary: nil,
                url: nil,
                data: [
                    AnalyticsConstants.Keys.toolOpenedShortcutCountKey: 1
                ]
            )
            
            successfullyHandledQuickAction = appDeepLinkingService.parseDeepLinkAndNotify(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: toolDeepLinkUrl)))
        }
        else {
            
            successfullyHandledQuickAction = false
        }

        return successfullyHandledQuickAction
    }
}
