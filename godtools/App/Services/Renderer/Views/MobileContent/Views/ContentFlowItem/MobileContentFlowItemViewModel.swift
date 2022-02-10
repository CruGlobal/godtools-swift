//
//  MobileContentFlowItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentFlowItemViewModel: MobileContentFlowItemViewModelType {
    
    private let flowItem: GodToolsToolParser.Flow.Item
    
    required init(flowItem: GodToolsToolParser.Flow.Item) {
        
        self.flowItem = flowItem
    }
    
    var width: MobileContentViewWidth {
        
        return MobileContentViewWidth(dimension: flowItem.width)
    }
}
