//
//  UIViewController+NavBackItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addDefaultNavBackItem() {
            
        guard let navigationController = navigationController else {
            return
        }
        
        if navigationController.viewControllers.count > 1 {
            _ = addBarButtonItem(
                to: .left,
                image: UIImage(named: "nav_item_back"),
                color: nil,
                target: self,
                action: #selector(handleNavBackItem(barButtonItem:))
            )
        }
    }
    
    @objc func handleNavBackItem(barButtonItem: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
