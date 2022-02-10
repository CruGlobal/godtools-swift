//
//  MobileContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentFormViewModel: MobileContentFormViewModelType {
    
    private let formModel: Form
    private let rendererPageModel: MobileContentRendererPageModel
            
    required init(formModel: Form, rendererPageModel: MobileContentRendererPageModel) {
        
        self.formModel = formModel
        self.rendererPageModel = rendererPageModel
    }
}
