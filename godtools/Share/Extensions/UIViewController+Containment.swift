//
//  UIViewController+Containment.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChildController(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
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
