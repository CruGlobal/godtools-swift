//
//  ToolPageModalsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageModalsViewModel: ToolPageModalsViewModelType {
    
    private let modalsModel: ModalsModelType
    private let pageModel: MobileContentRendererPageModel
    
    required init(modalsModel: ModalsModelType, pageModel: MobileContentRendererPageModel) {
        
        self.modalsModel = modalsModel
        self.pageModel = pageModel
    }
}
