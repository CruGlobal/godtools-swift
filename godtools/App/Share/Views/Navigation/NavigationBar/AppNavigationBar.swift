//
//  AppNavigationBar.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppNavigationBar {
    
    let leadingItems: [NavBarItem]
    let trailingItems: [NavBarItem]
            
    init(backButton: AppBackBarItem?, leadingItems: [NavBarItem], trailingItems: [NavBarItem]) {
        
        if let backButton = backButton {
            self.leadingItems = [backButton] + leadingItems
        }
        else {
            self.leadingItems = leadingItems
        }
        
        self.trailingItems = trailingItems
    }
}
