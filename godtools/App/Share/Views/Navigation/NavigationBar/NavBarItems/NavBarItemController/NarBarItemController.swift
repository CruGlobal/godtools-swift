//
//  NarBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class NarBarItemController {
        
    private var barButtonItem: UIBarButtonItem?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) weak var viewController: UIViewController?
    
    let navBarItem: NavBarItem
    let itemBarPosition: BarButtonItemBarPosition
    let itemIndex: Int
    
    init(viewController: UIViewController, navBarItem: NavBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int, shouldSinkToggleVisibility: Bool = true) {
        
        self.viewController = viewController
        self.navBarItem = navBarItem
        self.itemBarPosition = itemBarPosition
        self.itemIndex = itemIndex
        
        let newBarButtonItem: UIBarButtonItem = navBarItem.itemData.getNewBarButtonItem()
        
        self.barButtonItem = newBarButtonItem
                
        if shouldSinkToggleVisibility, let toggleVisibilityPublisher = navBarItem.toggleVisibilityPublisher {
            
            toggleVisibilityPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (hidden: Bool) in
                    self?.setHidden(hidden: hidden)
                }
                .store(in: &cancellables)
        }
        else {
            
            viewController.addBarButtonItem(item: newBarButtonItem, barPosition: itemBarPosition, index: itemIndex)
        }
    }
    
    static func newNavBarItemController(controllerType: NavBarItemControllerType, viewController: UIViewController, navBarItem: NavBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) -> NarBarItemController {
        
        let navBarItemController: NarBarItemController?
        
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
        
        return NarBarItemController(
            viewController: viewController,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
    }
    
    func getBarButtonItem() -> UIBarButtonItem? {
        return barButtonItem
    }
    
    func setBarButtonItem(barButtonItem: UIBarButtonItem) {
        
        guard let currentBarButtonItem = self.barButtonItem else {
            return
        }
        
        self.barButtonItem = barButtonItem
        
        viewController?.removeBarButtonItem(item: currentBarButtonItem)
        
        viewController?.addBarButtonItem(item: barButtonItem, barPosition: itemBarPosition, index: itemIndex)
    }
    
    func setHidden(hidden: Bool) {
        
        guard let barButtonItem = self.barButtonItem else {
            return
        }
        
        if hidden {
            viewController?.removeBarButtonItem(item: barButtonItem)
        }
        else {
            viewController?.addBarButtonItem(item: barButtonItem, barPosition: itemBarPosition, index: itemIndex)
        }
    }
}
