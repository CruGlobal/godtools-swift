//
//  CardJumpService.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class CardJumpService {
    
    private let cardJumpCache: CardJumpUserDefaultsCache
    
    required init(cardJumpCache: CardJumpUserDefaultsCache) {
        
        self.cardJumpCache = cardJumpCache
    }
    
    var didShowCardJump: Bool {
        return cardJumpCache.didShowCardJump
    }
    
    func saveDidShowCardJump() {
        if !didShowCardJump {
            cardJumpCache.cacheDidShowCardJump()
        }
    }
}
