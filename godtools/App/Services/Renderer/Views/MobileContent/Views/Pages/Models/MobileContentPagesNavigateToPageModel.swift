//
//  MobileContentPagesNavigateToPageModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentPagesNavigateToPageModel {
    
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
