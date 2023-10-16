//
//  AppNavigationBar.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppNavigationBar {
    
    private(set) var navBarItems: NavBarItems?
    
    let backButton: AppBackBarItem?
    let leadingItems: [NavBarItem]
    let trailingItems: [NavBarItem]
    
    init(backButton: AppBackBarItem?, leadingItems: [NavBarItem], trailingItems: [NavBarItem]) {
        
        self.backButton = backButton
        self.leadingItems = leadingItems
        self.trailingItems = trailingItems
    }
    
    func configure(viewController: UIViewController) {
        
        guard navBarItems == nil else {
            return
        }
        
        var leadingItemsWithBackButton: [NavBarItem] = leadingItems
        
        if let backButton = self.backButton {
            viewController.navigationItem.setHidesBackButton(true, animated: false)
            leadingItemsWithBackButton.insert(backButton, at: 0)
        }
        
        navBarItems = NavBarItems(
            viewController: viewController,
            leadingItems: leadingItemsWithBackButton,
            trailingItems: trailingItems
        )
    }
}
