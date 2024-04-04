//
//  MobileContentPagesNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentPagesNavigationEvent {
    
    let pageNavigation: PageNavigationCollectionViewNavigationModel
    let setPages: [Page]?
    let pagePositions: MobileContentViewPositionState?
    
    init(pageNavigation: PageNavigationCollectionViewNavigationModel, setPages: [Page]?, pagePositions: MobileContentViewPositionState?) {
        
        self.pageNavigation = pageNavigation
        self.setPages = setPages
        self.pagePositions = pagePositions
    }
}
