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
    private let pageModel: MobileContentRendererPageModel
            
    required init(modalModel: ModalModelType, pageModel: MobileContentRendererPageModel) {
        
        self.modalModel = modalModel
        self.pageModel = pageModel
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
    
    var listeners: [String] {
        return modalModel.listeners
    }
    
    var dismissListeners: [String] {
        return modalModel.dismissListeners
    }
}
