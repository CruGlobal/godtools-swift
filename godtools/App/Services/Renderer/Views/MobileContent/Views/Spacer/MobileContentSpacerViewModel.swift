//
//  MobileContentSpacerViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentSpacerViewModel: MobileContentSpacerViewModelType {
    
    private let spacerModel: ContentSpacerModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(spacerModel: ContentSpacerModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.spacerModel = spacerModel
        self.rendererPageModel = rendererPageModel
    }
    
    var mode: MobileContentSpacerMode {
        return spacerModel.mode
    }
    
    var height: CGFloat {
        return CGFloat(spacerModel.height)
    }
}
