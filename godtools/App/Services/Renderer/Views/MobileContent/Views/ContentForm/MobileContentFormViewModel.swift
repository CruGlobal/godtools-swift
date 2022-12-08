//
//  MobileContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentFormViewModel: MobileContentViewModel {
    
    private let formModel: Form
    private let renderedPageContext: MobileContentRenderedPageContext
            
    init(formModel: Form, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.formModel = formModel
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModel: formModel)
    }
}
