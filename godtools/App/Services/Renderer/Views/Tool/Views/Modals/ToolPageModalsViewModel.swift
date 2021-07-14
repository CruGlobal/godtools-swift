//
//  ToolPageModalsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageModalsViewModel: ToolPageModalsViewModelType {
    
    private let modalsNode: ModalsNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(modalsNode: ModalsNode, pageModel: MobileContentRendererPageModel) {
        
        self.modalsNode = modalsNode
        self.pageModel = pageModel
    }
}
