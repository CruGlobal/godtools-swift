//
//  ToolPageCallToActionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCallToActionViewModel: ToolPageCallToActionViewModelType {
    
    private let callToActionNode: CallToActionNode?
    private let pageModel: MobileContentRendererPageModel
    private let fontService: FontService
        
    required init(callToActionNode: CallToActionNode?, pageModel: MobileContentRendererPageModel, fontService: FontService) {
        
        self.callToActionNode = callToActionNode
        self.pageModel = pageModel
        self.fontService = fontService
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
    
    var title: String? {
        return callToActionNode?.textNode?.text
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var titleColor: UIColor {
        return callToActionNode?.textNode?.getTextColor()?.color ?? pageModel.pageColors.textColor
    }
    
    var nextButtonColor: UIColor {
        return callToActionNode?.getControlColor()?.color ?? pageModel.pageColors.primaryColor
    }
    
    var nextButtonImage: UIImage? {
        
        return UIImage(named: "right_arrow_blue")
    }
}
