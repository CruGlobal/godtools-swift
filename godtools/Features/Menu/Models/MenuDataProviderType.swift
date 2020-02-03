//
//  MenuDataProviderType.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MenuDataProviderType {
    
    func getMenuSection(id: MenuSectionId) -> MenuSection
    func getMenuItem(id: MenuItemId) -> MenuItem
}
