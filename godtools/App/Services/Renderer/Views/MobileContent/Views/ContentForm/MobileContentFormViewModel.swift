//
//  MobileContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentFormViewModel: MobileContentFormViewModelType {
    
    private let formModel: ContentFormModelType
    private let rendererPageModel: MobileContentRendererPageModel
            
    required init(formModel: ContentFormModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.formModel = formModel
        self.rendererPageModel = rendererPageModel
    }
}
