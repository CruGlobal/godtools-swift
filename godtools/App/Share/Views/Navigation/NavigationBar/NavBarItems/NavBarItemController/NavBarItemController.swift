//
//  NavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class NavBarItemController {
        
    private var toggleVisibilityPublisher: AnyPublisher<Bool, Never>?
    private var barButtonItem: UIBarButtonItem?
    private var currentIsHidden: Bool = true
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var viewController: UIViewController?
    
    let navBarItem: NavBarItem
    let itemBarPosition: BarButtonItemBarPosition
    let itemIndex: Int
    
    init(viewController: UIViewController, navBarItem: NavBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) {
        
        self.viewController = viewController
        self.navBarItem = navBarItem
        self.itemBarPosition = itemBarPosition
        self.itemIndex = itemIndex
        
        let newBarButtonItem: UIBarButtonItem = navBarItem.itemData.getNewBarButtonItem()
        
        self.toggleVisibilityPublisher = navBarItem.toggleVisibilityPublisher
        self.barButtonItem = newBarButtonItem
                
        if let toggleVisibilityPublisher = navBarItem.toggleVisibilityPublisher {
            
            toggleVisibilityPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (hidden: Bool) in
                    
                    let shouldToggleVisibility: Bool = self?.currentIsHidden != hidden
                    
                    if shouldToggleVisibility {
                        
                        self?.setHidden(hidden: hidden)
                    }
                    
                    self?.currentIsHidden = hidden
                }
                .store(in: &cancellables)
        }
        else {
            
            currentIsHidden = false
            viewController.addBarButtonItem(item: newBarButtonItem, barPosition: itemBarPosition, index: itemIndex)
        }
    }
    
    static func newNavBarItemController(controllerType: NavBarItemControllerType, viewController: UIViewController, navBarItem: NavBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) -> NavBarItemController {
        
        let navBarItemController: NavBarItemController?
        
        switch controllerType {
       
        case .appInterfaceString(let getInterfaceStringInAppLanguageUseCase):
            
            if let interfaceStringBarItem = navBarItem as? AppInterfaceStringBarItem {
                
                navBarItemController = AppInterfaceStringNavBarItemController(
                    viewController: viewController,
                    navBarItem: interfaceStringBarItem,
                    itemBarPosition: itemBarPosition,
                    itemIndex: itemIndex,
                    getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase
                )
            }
            else {
                
                assertionFailure("Failed to create NavBarItemController with appInterfaceString type.  Requires AppInterfaceStringBarItem.")
                
                navBarItemController = nil
            }
            
        case .appLayoutDirection:
            
            if let layoutDirectionBasedNavBarItem = navBarItem as? AppLayoutDirectionBasedBarItem {
                
                navBarItemController = AppLayoutDirectionNavBarItemController(
                    viewController: viewController,
                    navBarItem: layoutDirectionBasedNavBarItem,
                    itemBarPosition: itemBarPosition,
                    itemIndex: itemIndex
                )
            }
            else {
                
                assertionFailure("Failed to create NavBarItemController with appLayoutDirection type.  Requires AppLayoutDirectionBasedBarItem.")
                
                navBarItemController = nil
            }
            
        case .base:
            navBarItemController = nil
        }
        
        if let navBarItemController = navBarItemController {
            return navBarItemController
        }
        
        return NavBarItemController(
            viewController: viewController,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
    }

    func getBarButtonItem() -> UIBarButtonItem? {
        return barButtonItem
    }
    
    func reDrawBarButtonItem(barButtonItem: UIBarButtonItem) {
        
        guard let viewController = self.viewController else {
            return
        }
        
        guard let currentBarButtonItem = self.barButtonItem else {
            return
        }
        
        self.barButtonItem = barButtonItem
        
        if !currentIsHidden {
            
            viewController.removeBarButtonItem(item: currentBarButtonItem)
            
            viewController.addBarButtonItem(item: barButtonItem, barPosition: itemBarPosition, index: itemIndex)
        }
    }
    
    private func setHidden(hidden: Bool) {
        
        guard let viewController = self.viewController else {
            return
        }
        
        guard let barButtonItem = self.barButtonItem else {
            return
        }
        
        if hidden {
            
            viewController.removeBarButtonItem(item: barButtonItem)
        }
        else {
            
            viewController.addBarButtonItem(item: barButtonItem, barPosition: itemBarPosition, index: itemIndex)
        }
    }
}
