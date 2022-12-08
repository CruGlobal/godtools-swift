//
//  MobileContentHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentHeaderViewModel: MobileContentViewModel {
    
    private let headerModel: Text
    private let renderedPageContext: MobileContentRenderedPageContext
    
    init(headerModel: Text, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.headerModel = headerModel
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModel: headerModel)
    }
    
    var fontSize: CGFloat {
        return 20
    }
    
    var fontWeight: UIFont.Weight {
        return .semibold
    }
    
    var textColor: UIColor {
        return .magenta
    }
}
