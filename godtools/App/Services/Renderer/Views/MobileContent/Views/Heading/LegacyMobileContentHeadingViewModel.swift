//
//  LegacyMobileContentHeadingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class LegacyMobileContentHeadingViewModel: LegacyMobileContentViewModel {
    
    private let headingModel: Text
    
    init(
        headingModel: Text,
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics
    ) {
        
        self.headingModel = headingModel
        
        super.init(baseModel: headingModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var fontSize: CGFloat {
        return 30
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        
        return headingModel.textColor.toUIColor()
    }
}
