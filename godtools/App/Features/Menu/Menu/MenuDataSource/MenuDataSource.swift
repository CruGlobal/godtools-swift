//
//  MenuDataSource.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MenuDataSource {
    
    let sections: [MenuSection]
    let items: [MenuSection: [MenuItem]]
}

extension MenuDataSource {
    static func createEmptyDataSource() -> MenuDataSource {
        return MenuDataSource(sections: [], items: [: ])
    }
}

extension MenuDataSource {
    
    func getMenuItem(at indexPath: IndexPath) -> MenuItem {
        
        let menuSection: MenuSection = sections[indexPath.section]
        let menuItems: [MenuItem] = items[menuSection] ?? []
        return menuItems[indexPath.row]
    }
}
