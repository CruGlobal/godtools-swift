//
//  CardJumpService.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class CardJumpService: Sendable {
    
    private let cardJumpCache: CardJumpUserDefaultsCache
        
    init(cardJumpCache: CardJumpUserDefaultsCache) {
        
        self.cardJumpCache = cardJumpCache
    }
    
    var didShowCardJump: Bool {
        get async {
            return await cardJumpCache.didShowCardJump
        }
    }
    
    func saveDidShowCardJump() async {
        await cardJumpCache.cacheDidShowCardJump()
    }
}
