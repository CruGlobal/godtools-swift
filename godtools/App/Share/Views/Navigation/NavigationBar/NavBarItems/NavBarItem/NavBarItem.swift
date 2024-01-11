//
//  NavBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class NavBarItem {
    
    let controllerType: NavBarItemControllerType
    let itemData: NavBarItemData
    let hidesBarItemPublisher: AnyPublisher<Bool, Never>?
        
    init(controllerType: NavBarItemControllerType, itemData: NavBarItemData, hidesBarItemPublisher: AnyPublisher<Bool, Never>?) {
        
        self.controllerType = controllerType
        self.itemData = itemData
        self.hidesBarItemPublisher = hidesBarItemPublisher
    }
}
