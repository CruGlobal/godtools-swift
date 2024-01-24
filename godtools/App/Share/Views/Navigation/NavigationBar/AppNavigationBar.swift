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
    private let backButton: AppBackBarItem?
    private let leadingItems: [NavBarItem]
    private let trailingItems: [NavBarItem]
    private let initialTitleView: UIView?
    private let initialTitle: String?
    
    private var leadingItemControllers: [NavBarItemController] = Array()
    private var trailingItemControllers: [NavBarItemController] = Array()
    private var titleView: UIView?
    private var title: String?
    private var didConfigure: Bool = false
        
    private weak var viewController: UIViewController?
    
    init(appearance: AppNavigationBarAppearance?, backButton: AppBackBarItem?, leadingItems: [NavBarItem], trailingItems: [NavBarItem], titleView: UIView? = nil, title: String? = nil) {
        
        self.appearance = appearance
        self.backButton = backButton
        self.leadingItems = leadingItems
        self.trailingItems = trailingItems
        self.initialTitleView = titleView
        self.initialTitle = title
        self.titleView = titleView
        self.title = title
    }
    
    private static func getItemControllers(viewController: UIViewController, items: [NavBarItem], barPosition: BarButtonItemBarPosition) -> [NavBarItemController] {
        
        var itemControllers: [NavBarItemController] = Array()
        
        for index in 0 ..< items.count {
            
            let navBarItem: NavBarItem = items[index]
            
            let controller = NavBarItemController.newNavBarItemController(
                controllerType: navBarItem.controllerType,
                viewController: viewController,
                navBarItem: navBarItem,
                itemBarPosition: barPosition,
                itemIndex: index
            )
            
            itemControllers.append(controller)
        }
        
        return itemControllers
    }
    
    func resetToInitialState() {
        
        guard let viewController = self.viewController else {
            return
        }
        
        didConfigure = false
        
        configureIfNeeded(viewController: viewController)
    }
    
    private func configureIfNeeded(viewController: UIViewController) {
        
        guard !didConfigure else {
            return
        }
        
        didConfigure = true
        
        reconfigureAppearnce(viewController: viewController)
        
        reconfigureButtonItems(viewController: viewController)
                
        if let titleView = self.titleView {
            setTitleView(titleView: titleView)
        }
        else if let title = title {
            setTitle(title: title)
        }
    }
    
    private func reconfigureAppearnce(viewController: UIViewController) {
        
        if let appearance = appearance, let navigationBar = viewController.navigationController?.navigationBar {

            navigationBar.setupNavigationBarAppearance(
                backgroundColor: appearance.backgroundColor,
                controlColor: appearance.controlColor,
                titleFont: appearance.titleFont,
                titleColor: appearance.titleColor,
                isTranslucent: appearance.isTranslucent
            )
        }
    }
    
    private func reconfigureButtonItems(viewController: UIViewController) {
        
        viewController.removeAllBarButtonItems()
        leadingItemControllers.removeAll()
        trailingItemControllers.removeAll()
        
        var leadingItemsWithBackButton: [NavBarItem] = leadingItems
        
        if let backButton = self.backButton {
            viewController.navigationItem.setHidesBackButton(true, animated: false)
            leadingItemsWithBackButton.insert(backButton, at: 0)
        }
        
        leadingItemControllers = AppNavigationBar.getItemControllers(
            viewController: viewController,
            items: leadingItems,
            barPosition: .leading
        )
        
        trailingItemControllers = AppNavigationBar.getItemControllers(
            viewController: viewController,
            items: trailingItems,
            barPosition: .trailing
        )
    }
    
    func willAppear(viewController: UIViewController, animated: Bool) {
         
        self.viewController = viewController
        
        configureIfNeeded(viewController: viewController)
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
