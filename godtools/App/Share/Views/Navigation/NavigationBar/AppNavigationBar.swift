//
//  AppNavigationBar.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppNavigationBar {
    
    private let appearance: AppNavigationBarAppearance?
    private let titleView: UIView?

    private(set) var navBarItems: NavBarItems?
    
    private weak var viewController: UIViewController?
    
    let backButton: AppBackBarItem?
    let leadingItems: [NavBarItem]
    let trailingItems: [NavBarItem]
    
    init(appearance: AppNavigationBarAppearance?, backButton: AppBackBarItem?, leadingItems: [NavBarItem], trailingItems: [NavBarItem], titleView: UIView? = nil) {
        
        self.appearance = appearance
        self.backButton = backButton
        self.leadingItems = leadingItems
        self.trailingItems = trailingItems
        self.titleView = titleView
    }
    
    private func setAppearance() {
        
        guard let navigationController = viewController?.navigationController, let appearance = self.appearance else {
            return
        }
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: appearance.backgroundColor,
            controlColor: appearance.controlColor,
            titleFont: appearance.titleFont,
            titleColor: appearance.titleColor,
            isTranslucent: appearance.isTranslucent
        )
    }
    
    func configure(viewController: UIViewController) {
        
        guard navBarItems == nil else {
            return
        }
        
        self.viewController = viewController
        
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
        
        if let titleView = self.titleView {
            viewController.navigationItem.titleView = titleView
        }
    }
    
    func willAppear(animated: Bool) {
                
        setAppearance()
    }
}
