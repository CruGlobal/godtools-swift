//
//  MobileContentPageCollectionPositionState.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class MobileContentPageCollectionPositionState: MobileContentViewPositionState {
        
    let currentPageNumber: Int
    
    init(currentPageNumber: Int) {
        
        self.currentPageNumber = currentPageNumber
    }
}
