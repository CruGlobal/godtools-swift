//
//  ToolPageModalsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolPageModalsViewModel: ToolPageModalsViewModelType {
    
    private let modals: [Modal]
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(modals: [Modal], rendererPageModel: MobileContentRendererPageModel) {
        
        self.modals = modals
        self.rendererPageModel = rendererPageModel
    }
}
