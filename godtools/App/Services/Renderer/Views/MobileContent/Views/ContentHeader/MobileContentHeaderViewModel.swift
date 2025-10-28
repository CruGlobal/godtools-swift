//
//  MobileContentHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MobileContentHeaderViewModel: MobileContentViewModel {
    
    private let headerModel: Text
    
    init(headerModel: Text, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.headerModel = headerModel
        
        super.init(baseModel: headerModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
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
