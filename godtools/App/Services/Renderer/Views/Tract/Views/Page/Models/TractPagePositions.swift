//
//  File.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TractPagePositions: MobileContentViewPositionState {
    
    let cardPosition: Int?
    
    init(cardPosition: Int?) {
        
        self.cardPosition = cardPosition
    }
}
