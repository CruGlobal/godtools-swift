//
//  NavBarItems.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class NavBarItems {
        
    private let leadingItemControllers: [NarBarItemController]
    private let trailingItemControllers: [NarBarItemController]
            
    init(viewController: UIViewController, leadingItems: [NavBarItem], trailingItems: [NavBarItem]) {
        
        leadingItemControllers = NavBarItems.getItemControllers(
            viewController: viewController,
            items: leadingItems,
            itemBarPosition: .left
        )
        
        trailingItemControllers = NavBarItems.getItemControllers(
            viewController: viewController,
            items: trailingItems,
            itemBarPosition: .right
        )
    }
    
    private static func getItemControllers(viewController: UIViewController, items: [NavBarItem], itemBarPosition: BarButtonItemBarPosition) -> [NarBarItemController] {
        
        var itemControllers: [NarBarItemController] = Array()
        
        for index in 0 ..< items.count {
            
            let navBarItem: NavBarItem = items[index]
            
            let controller = NarBarItemController.newNavBarItemController(
                controllerType: navBarItem.controllerType,
                viewController: viewController,
                navBarItem: navBarItem,
                itemBarPosition: itemBarPosition,
                itemIndex: index
            )
            
            itemControllers.append(controller)
        }
        
        return itemControllers
    }
}
