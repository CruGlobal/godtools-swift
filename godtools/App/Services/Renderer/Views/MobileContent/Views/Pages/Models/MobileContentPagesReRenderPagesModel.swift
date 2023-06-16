//
//  MobileContentPagesReRenderPagesModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit

class MobileContentPagesReRenderPagesModel {
    
    let pagesSemanticContentAttribute: UISemanticContentAttribute?
    let navigateToPageModel: MobileContentPagesNavigateToPageModel?
    
    init(pagesSemanticContentAttribute: UISemanticContentAttribute?, navigateToPageModel: MobileContentPagesNavigateToPageModel?) {
        
        self.pagesSemanticContentAttribute = pagesSemanticContentAttribute
        self.navigateToPageModel = navigateToPageModel
    }
}
