//
//  MobileContentFlowViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentFlowViewModel: MobileContentFlowViewModelType {
    
    private let contentFlow: MultiplatformContentFlow
    
    required init(contentFlow: MultiplatformContentFlow) {
        
        self.contentFlow = contentFlow
    }
}
