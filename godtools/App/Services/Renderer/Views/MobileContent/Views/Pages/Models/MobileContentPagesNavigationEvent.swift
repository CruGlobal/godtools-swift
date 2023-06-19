//
//  MobileContentPagesNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MobileContentPagesNavigationEvent {
    
    let page: Int
    let insertPages: [Int]?
    let animated: Bool
    
    init(page: Int, insertPages: [Int]?, animated: Bool) {
        
        self.page = page
        self.insertPages = insertPages
        self.animated = animated
    }
}
