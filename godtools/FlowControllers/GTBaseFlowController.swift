//
//  GTBaseFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTBaseFlowController: NSObject, UINavigationControllerDelegate {
    
    var currentViewController: UIViewController?
    
    init(window: UIWindow, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        super.init()
        self.currentViewController = self.initialViewController()
        let navigationController = UINavigationController.init(rootViewController: self.currentViewController!)
        navigationController.delegate = self
        window.rootViewController = navigationController
    }
    
    func initialViewController() -> UIViewController {
        preconditionFailure("This method must be overridden")
    }
    
    func pushViewController(viewController: UIViewController) {
        self.currentViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Navigation Controller Delegate
    
}
