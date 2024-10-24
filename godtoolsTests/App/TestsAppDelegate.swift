//
//  TestsAppDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

@objc(TestsAppDelegate)
class TestsAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
   
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        let viewController = UIViewController(nibName: nil, bundle: nil)
        viewController.view.backgroundColor = .red
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
        
        self.window = window
    }
}
