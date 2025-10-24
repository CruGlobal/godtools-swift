//
//  MobileContentPagesNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class MobileContentPagesNavigationEvent {
    
    let pageNavigation: PageNavigationCollectionViewNavigationModel
    let setPages: [Page]?
    let pagePositions: MobileContentViewPositionState?
    let parentPageParams: MobileContentParentPageParams?
    let pageSubIndex: Int?
    
    init(pageNavigation: PageNavigationCollectionViewNavigationModel, setPages: [Page]?, pagePositions: MobileContentViewPositionState?, parentPageParams: MobileContentParentPageParams?, pageSubIndex: Int?) {
        
        self.pageNavigation = pageNavigation
        self.setPages = setPages
        self.pagePositions = pagePositions
        self.parentPageParams = parentPageParams
        self.pageSubIndex = pageSubIndex
    }
}
