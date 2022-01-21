//
//  MultiplatformTip.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformTip: TipModelType {
    
    private let tip: Tip
    
    required init(tip: Tip) {
        
        self.tip = tip
    }
    
    var id: String {
        return tip.id
    }
    
    var tipType: MobileContentTrainingTipType {
        
        switch tip.type {
        case .ask:
            return .ask
        case .consider:
            return .consider
        case .prepare:
            return .prepare
        case .quote:
            return .quote
        case .tip:
            return .tip
        default:
            assertionFailure("Found unsupported tipType: \(tip.type). Ensure all types are supported.")
            return .unknown
        }
    }
    
    var pages: [PageModelType] {
        return tip.pages.map({MultiplatformTipPage(tipPage: $0)})
    }
}
