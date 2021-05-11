//
//  MobileContentSpacerViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentSpacerViewModel: MobileContentSpacerViewModelType {
    
    private let spacerNode: ContentSpacerNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(spacerNode: ContentSpacerNode, pageModel: MobileContentRendererPageModel) {
        
        self.spacerNode = spacerNode
        self.pageModel = pageModel
    }
    
    var mode: MobileContentSpacerMode {
        return spacerNode.spacerMode
    }
    
    var height: CGFloat {
        
        if let height = spacerNode.height, !height.isEmpty, let floatValue = Float(height) {
            return CGFloat(floatValue)
        }
        
        return 20
    }
}
