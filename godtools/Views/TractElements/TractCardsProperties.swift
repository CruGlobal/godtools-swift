//
//  TractCardsProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCardsProperties: TractProperties {
    
    enum CardsState {
        case open, preview
    }
    
    // MARK: - View Properties
    
    var cardsState = CardsState.preview

}
