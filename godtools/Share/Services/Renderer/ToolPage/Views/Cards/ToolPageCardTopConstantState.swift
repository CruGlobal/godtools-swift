//
//  ToolPageCardTopConstantState.swift
//  godtools
//
//  Created by Levi Eggert on 11/5/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ToolPageCardTopConstantState {
    
    case starting(cardPosition: Int)
    case showing
    case collapsed(cardPosition: Int)
    case hidden
}
