//
//  MenuCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MenuCellViewModel {
    
    let title: String
    
    required init(menuItem: MenuItem) {
        title = menuItem.title
    }
}
