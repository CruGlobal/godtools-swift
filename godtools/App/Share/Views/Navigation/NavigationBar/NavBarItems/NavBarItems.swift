//
//  NavBarItems.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class NavBarItems {
        
    private let leadingItemControllers: [NavBarItemController]
    private let trailingItemControllers: [NavBarItemController]
                
    init(viewController: UIViewController, leadingItems: [NavBarItem], trailingItems: [NavBarItem]) {
        
        leadingItemControllers = NavBarItems.getItemControllers(
            viewController: viewController,
            items: leadingItems,
            barPosition: .leading
        )
        
        trailingItemControllers = NavBarItems.getItemControllers(
            viewController: viewController,
            items: trailingItems,
            barPosition: .trailing
        )
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
}
