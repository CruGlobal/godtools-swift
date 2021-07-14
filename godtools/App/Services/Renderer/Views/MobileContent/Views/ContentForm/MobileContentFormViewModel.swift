//
//  MobileContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentFormViewModel: MobileContentFormViewModelType {
    
    private let formNode: ContentFormNode
    private let pageModel: MobileContentRendererPageModel
            
    required init(formNode: ContentFormNode, pageModel: MobileContentRendererPageModel) {
        
        self.formNode = formNode
        self.pageModel = pageModel
    }
}
