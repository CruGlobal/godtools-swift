//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageModalViewModel: ToolPageModalViewModelType {
    
    private let modalModel: Modal
    private let renderedPageContext: MobileContentRenderedPageContext
            
    required init(modalModel: Modal, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.modalModel = modalModel
        self.renderedPageContext = renderedPageContext
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
    
    var listeners: [EventId] {
        return Array(modalModel.listeners)
    }
    
    var dismissListeners: [EventId] {
        return Array(modalModel.dismissListeners)
    }
}
