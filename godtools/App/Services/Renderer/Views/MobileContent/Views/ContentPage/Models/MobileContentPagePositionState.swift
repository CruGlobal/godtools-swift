//
//  MobileContentPagePositionState.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentPagePositionState: MobileContentViewPositionState {
    
    let scrollContentOffset: CGPoint
    
    required init(scrollContentOffset: CGPoint) {
        
        self.scrollContentOffset = scrollContentOffset
    }
}
