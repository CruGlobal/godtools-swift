//
//  AppNavigationBar.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppNavigationBar {
    
    private var appearance: AppNavigationBarAppearance?
    private var titleView: UIView?
    private var title: String?
    
    private(set) var navBarItems: NavBarItems?
    
    private weak var viewController: UIViewController?
    
    let backButton: AppBackBarItem?
    let leadingItems: [NavBarItem]
    let trailingItems: [NavBarItem]
    
    init(appearance: AppNavigationBarAppearance?, backButton: AppBackBarItem?, leadingItems: [NavBarItem], trailingItems: [NavBarItem], titleView: UIView? = nil, title: String? = nil) {
        
        self.appearance = appearance
        self.backButton = backButton
        self.leadingItems = leadingItems
        self.trailingItems = trailingItems
        self.titleView = titleView
        self.title = title
    }
    
    func setAppearance(appearance: AppNavigationBarAppearance) {
        
        self.appearance = appearance
        
        guard let navigationBar = viewController?.navigationController?.navigationBar else {
            return
        }
        
        navigationBar.setupNavigationBarAppearance(
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
            setTitleView(titleView: titleView)
        }
        else if let title = title {
            setTitle(title: title)
        }
    }
    
    func willAppear(animated: Bool) {
                
        if let appearance = self.appearance {
            setAppearance(appearance: appearance)
        }
    }
    
    func getTitleView() -> UIView? {
        return titleView
    }
    
    func setTitleView(titleView: UIView?) {
        
        self.titleView = titleView
        
        viewController?.title = nil
        viewController?.navigationItem.titleView = titleView
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func setTitle(title: String?) {
        
        self.title = title
        
        viewController?.navigationItem.titleView = nil
        viewController?.title = title
    }
}
