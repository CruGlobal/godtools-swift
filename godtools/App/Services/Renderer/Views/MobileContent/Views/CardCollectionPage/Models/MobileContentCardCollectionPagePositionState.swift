//
//  MobileContentCardCollectionPagePositionState.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentCardCollectionPagePositionState: MobileContentViewPositionState {
    
    let currentCardId: String
    
    required init(currentCardId: String) {
        
        self.currentCardId = currentCardId
    }
}
