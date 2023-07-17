//
//  MobileContentPagesNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentPagesNavigationEvent {
    
    let pageNavigation: PageNavigationCollectionViewNavigationModel
    let pagePositions: MobileContentViewPositionState?
    
    init(pageNavigation: PageNavigationCollectionViewNavigationModel, pagePositions: MobileContentViewPositionState?) {
        
        self.pageNavigation = pageNavigation
        self.pagePositions = pagePositions
    }
}
