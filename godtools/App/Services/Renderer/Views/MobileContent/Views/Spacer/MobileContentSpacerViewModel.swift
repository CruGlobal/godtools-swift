//
//  MobileContentSpacerViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentSpacerViewModel: MobileContentViewModel {
    
    private let spacerModel: Spacer
    
    let height: MobileContentSpacerHeight
    
    init(spacerModel: Spacer, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.spacerModel = spacerModel
        
        switch spacerModel.mode {
        case .auto_:
            height = .auto
        case .fixed:
            height = .fixed(height: CGFloat(spacerModel.height))
        default:
            height = .auto
        }
        
        super.init(baseModel: spacerModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
