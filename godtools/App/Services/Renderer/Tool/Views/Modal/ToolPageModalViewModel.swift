//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageModalViewModel: ToolPageModalViewModelType {
    
    private let modalNode: ModalNode
    private let pageModel: MobileContentRendererPageModel
            
    required init(modalNode: ModalNode, pageModel: MobileContentRendererPageModel) {
        
        self.modalNode = modalNode
        self.pageModel = pageModel
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
    
    var listeners: [String] {
        return modalNode.listeners
    }
    
    var dismissListeners: [String] {
        return modalNode.dismissListeners
    }
}
