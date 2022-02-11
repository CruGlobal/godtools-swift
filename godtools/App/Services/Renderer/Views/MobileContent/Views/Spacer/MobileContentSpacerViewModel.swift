//
//  MobileContentSpacerViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentSpacerViewModel: MobileContentSpacerViewModelType {
    
    private let spacerModel: Spacer
    private let rendererPageModel: MobileContentRendererPageModel
    
    let height: MobileContentSpacerHeight
    
    required init(spacerModel: Spacer, rendererPageModel: MobileContentRendererPageModel) {
        
        self.spacerModel = spacerModel
        self.rendererPageModel = rendererPageModel
        
        switch spacerModel.mode {
        case .auto_:
            height = .auto
        case .fixed:
            height = .fixed(height: CGFloat(spacerModel.height))
        default:
            height = .auto
        }
    }
}
