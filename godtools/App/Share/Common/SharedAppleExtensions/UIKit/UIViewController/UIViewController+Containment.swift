//
//  UIViewController+Containment.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func addChildController(child: UIViewController, toView: UIView? = nil) {
        addChild(child)
        let parentView: UIView = toView ?? view
        parentView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChildController(child: UIViewController) {
        child.removeAsChildController()
    }
    
    func removeAsChildController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
