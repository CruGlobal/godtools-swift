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
    private let pageModel: MobileContentRendererPageModel
    
    required init(spacerModel: ContentSpacerModelType, pageModel: MobileContentRendererPageModel) {
        
        self.spacerModel = spacerModel
        self.pageModel = pageModel
    }
    
    var mode: MobileContentSpacerMode {
        return spacerModel.spacerMode
    }
    
    var height: CGFloat {
        
        if let height = spacerModel.height, !height.isEmpty, let floatValue = Float(height) {
            return CGFloat(floatValue)
        }
        
        return 20
    }
}
