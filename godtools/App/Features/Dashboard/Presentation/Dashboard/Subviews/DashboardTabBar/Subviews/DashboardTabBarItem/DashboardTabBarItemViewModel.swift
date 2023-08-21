//
//  DashboardTabBarItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DashboardTabBarItemViewModel {
    
    let tab: DashboardTabTypeDomainModel
    let title: String
    let imageName: String
    
    init(tab: DashboardTabTypeDomainModel, title: String, imageName: String) {
        
        self.tab = tab
        self.title = title
        self.imageName = imageName
    }
}
