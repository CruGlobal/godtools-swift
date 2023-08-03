//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageModalViewModel: MobileContentViewModel {
    
    private let modalModel: Modal
            
    init(modalModel: Modal, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.modalModel = modalModel
        
        super.init(baseModel: modalModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
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
