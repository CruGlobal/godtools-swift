//
//  TractCards+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension TractCards {
    
    func getHeightOfClosedCards() -> CGFloat {
        let cards = splitCardsByKind()
        return CGFloat(cards.normal.count) * TractCards.constantYPaddingTop
    }
    
    func getMaxFreeHeight(hero previousElement: TractHero) -> CGFloat {
        let maxHeight = BaseTractElement.screenHeight - previousElement.elementFrame.y - TractHero.marginBottom
        return maxHeight - getHeightOfClosedCards()
    }
    
    func setCardsYPosition() {
        if let element = getPreviousElement() as? TractHero {
            let initialYPosition = getMaxFreeHeight(hero: element)
            if initialYPosition < self.elementFrame.y {
                self.elementFrame.y = (UIDevice.current.iPhoneWithNotch()) ? initialYPosition - TractPage.navbarHeight : initialYPosition + TractPage.navbarHeight
            }
        }
    }
    
}
