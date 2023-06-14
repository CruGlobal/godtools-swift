//
//  UIViewController+AppNavBackButton.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addDefaultNavBackItem(target: Any, action: Selector) -> UIBarButtonItem? {
            
        navigationItem.setHidesBackButton(true, animated: false)
                
        return addBarButtonItem(
            to: .left,
            image: ImageCatalog.navBack.uiImage,
            color: nil,
            target: target,
            action: action
        )
    }
}
