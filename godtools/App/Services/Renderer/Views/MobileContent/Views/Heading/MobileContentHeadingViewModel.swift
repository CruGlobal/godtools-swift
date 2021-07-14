//
//  MobileContentHeadingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentHeadingViewModel: MobileContentHeadingViewModelType {
    
    private let headingModel: HeadingModelType
    private let pageModel: MobileContentRendererPageModel
    
    required init(headingModel: HeadingModelType, pageModel: MobileContentRendererPageModel) {
        
        self.headingModel = headingModel
        self.pageModel = pageModel
    }
    
    var fontSize: CGFloat {
        return 30
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        
        return headingModel.getTextColor()?.color ?? pageModel.pageColors.primaryColor
    }
}
