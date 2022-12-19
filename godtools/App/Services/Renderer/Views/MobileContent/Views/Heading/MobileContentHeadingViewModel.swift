//
//  MobileContentHeadingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentHeadingViewModel: MobileContentViewModel {
    
    private let headingModel: Text
    
    init(headingModel: Text, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.headingModel = headingModel
        
        super.init(baseModel: headingModel, renderedPageContext: renderedPageContext)
    }
    
    var fontSize: CGFloat {
        return 30
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        
        return headingModel.textColor
    }
}
