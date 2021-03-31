//
//  MobileContentHeadingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentHeadingViewModel: MobileContentHeadingViewModelType {
    
    private let headingNode: HeadingNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(headingNode: HeadingNode, pageModel: MobileContentRendererPageModel) {
        
        self.headingNode = headingNode
        self.pageModel = pageModel
    }
    
    var fontSize: CGFloat {
        return 30
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        
        return headingNode.textNode?.getTextColor()?.color ?? pageModel.pageColors.primaryColor
    }
}
