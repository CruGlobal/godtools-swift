//
//  TractCards+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCards {
    
    func getHeightOfClosedCards() -> CGFloat {
        let cards = splitCardsByKind()
        return CGFloat(cards.normal.count) * TractCards.constantYPaddingTop
    }
    
    func getMaxFreeHeight() -> CGFloat {
        let element = getPreviousElement()
        if element != nil && element!.isKind(of: TractHero.self) {
            let maxHeight = BaseTractElement.screenHeight - element!.elementFrame.y - TractHero.marginBottom
            return maxHeight - getHeightOfClosedCards()
        }
        return 0.0
    }
    
    func setCardsYPosition() {
        let element = getPreviousElement()
        if element != nil && element!.isKind(of: TractHero.self) {
            let initialYPosition = getMaxFreeHeight()
            if initialYPosition < self.elementFrame.y {
                self.elementFrame.y = initialYPosition + TractPage.navbarHeight
            }
        }
    }
    
}
