//
//  ToolPageCardsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolPageCardsViewModelType {
    
    var currentCard: ObservableValue<AnimatableValue<Int?>> { get }
    var numberOfCards: Int { get }
    var numberOfVisibleCards: Int { get }
}
