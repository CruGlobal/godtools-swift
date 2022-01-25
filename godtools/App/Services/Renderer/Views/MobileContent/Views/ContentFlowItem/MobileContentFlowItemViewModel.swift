//
//  MobileContentFlowItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentFlowItemViewModel: MobileContentFlowItemViewModelType {
    
    private let flowItem: MultiplatformContentFlowItem
    
    required init(flowItem: MultiplatformContentFlowItem) {
        
        self.flowItem = flowItem
    }
}
