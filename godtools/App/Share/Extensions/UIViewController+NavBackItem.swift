//
//  UIViewController+NavBackItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // TODO: (DEPRECATED) Eventually I want this to be removed and instead use addDefaultNavBackItem(target: Any, selector: Selector). This way back navigation can be wired through flows. ~Levi
    @available(*, deprecated)
    func addDefaultNavBackItem() -> UIBarButtonItem? {
          
        return addDefaultNavBackItem(
            target: self,
            action: #selector(handleNavBackItem(barButtonItem:))
        )
    }
    
    func addDefaultNavBackItem(target: Any, action: Selector) -> UIBarButtonItem? {
            
        guard let navigationController = navigationController else {
            return nil
        }
        
        guard navigationController.viewControllers.count > 1 else {
            return nil
        }
        
        return addBarButtonItem(
            to: .left,
            image: ImageCatalog.navBack.image,
            color: nil,
            target: target,
            action: action
        )
    }
    
    @objc func handleNavBackItem(barButtonItem: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
