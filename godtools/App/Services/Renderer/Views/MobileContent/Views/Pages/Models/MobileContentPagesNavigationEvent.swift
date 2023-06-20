//
//  MobileContentPagesNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MobileContentPagesNavigationEvent {
    
    let reloadPagesCollectionViewNeeded: Bool
    let page: Int
    let pagePositions: MobileContentViewPositionState?
    let animated: Bool
    
    init(reloadPagesCollectionViewNeeded: Bool, page: Int, pagePositions: MobileContentViewPositionState?, animated: Bool) {
        
        self.reloadPagesCollectionViewNeeded = reloadPagesCollectionViewNeeded
        self.page = page
        self.pagePositions = pagePositions
        self.animated = animated
    }
}
