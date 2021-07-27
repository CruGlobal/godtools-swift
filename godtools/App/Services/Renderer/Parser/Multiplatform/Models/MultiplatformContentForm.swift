//
//  MultiplatformContentForm.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentForm: ContentFormModelType {
    
    private let form: Form
    
    required init(form: Form) {
        
        self.form = form
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentForm {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
