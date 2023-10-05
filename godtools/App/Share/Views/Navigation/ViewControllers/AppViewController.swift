//
//  AppViewController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {
    
    private var navBarItems: NavBarItems?
    
    init(navigationBar: AppNavigationBar?) {
                
        super.init(nibName: nil, bundle: nil)
        
        if let navigationBar = navigationBar {
            navBarItems = NavBarItems(viewController: self, leadingItems: navigationBar.leadingItems, trailingItems: navigationBar.trailingItems)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
