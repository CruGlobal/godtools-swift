//
//  CardJumpService.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class CardJumpService {
    
    private let cardJumpCache: CardJumpUserDefaultsCache
    
    private let didSaveCardJumpShownSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    init(cardJumpCache: CardJumpUserDefaultsCache) {
        
        self.cardJumpCache = cardJumpCache
    }
    
    var didSaveCardJumpPublisher: AnyPublisher<Void, Never> {
        return didSaveCardJumpShownSubject
            .eraseToAnyPublisher()
    }
    
    var didShowCardJump: Bool {
        return cardJumpCache.didShowCardJump
    }
    
    func saveDidShowCardJump() {
        cardJumpCache.cacheDidShowCardJump()
        didSaveCardJumpShownSubject.send(Void())
    }
}
