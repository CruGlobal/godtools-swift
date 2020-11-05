//
//  ToolPageCardsState.swift
//  godtools
//
//  Created by Levi Eggert on 11/5/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ToolPageCardsState: Equatable {
    
    case starting
    case showingCard(showingCardAtPosition: Int?)
    case collapseAllCards
    case initialized
}
