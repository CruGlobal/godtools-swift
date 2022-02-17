//
//  MobileContentCardCollectionPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol MobileContentCardCollectionPageViewModelType: MobileContentPageViewModelType {
    
    func getCardId(card: Int) -> String
    func getCardPosition(cardId: String) -> Int?
    func pageDidAppear()
    func cardDidAppear(card: Int)
}
