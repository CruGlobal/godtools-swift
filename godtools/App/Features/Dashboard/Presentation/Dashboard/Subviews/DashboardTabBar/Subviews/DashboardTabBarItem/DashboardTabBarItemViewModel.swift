//
//  DashboardTabBarItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DashboardTabBarItemViewModel {
    
    let tabIndex: Int
    let title: String
    let imageName: String
    
    init(tabIndex: Int, title: String, imageName: String) {
        
        self.tabIndex = tabIndex
        self.title = title
        self.imageName = imageName
    }
}
