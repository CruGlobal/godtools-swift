//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageModalViewModel: ToolPageModalViewModelType {
    
    private let modalModel: ModalModelType
    private let rendererPageModel: MobileContentRendererPageModel
            
    required init(modalModel: ModalModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.modalModel = modalModel
        self.rendererPageModel = rendererPageModel
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
    
    var listeners: [MultiplatformEventId] {
        return modalModel.listeners
    }
    
    var dismissListeners: [MultiplatformEventId] {
        return modalModel.dismissListeners
    }
}
