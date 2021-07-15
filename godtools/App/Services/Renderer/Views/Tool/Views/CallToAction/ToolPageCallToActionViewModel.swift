//
//  ToolPageCallToActionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCallToActionViewModel: ToolPageCallToActionViewModelType {
    
    private let callToActionModel: CallToActionModelType?
    private let pageModel: MobileContentRendererPageModel
    private let fontService: FontService
        
    required init(callToActionModel: CallToActionModelType?, pageModel: MobileContentRendererPageModel, fontService: FontService) {
        
        self.callToActionModel = callToActionModel
        self.pageModel = pageModel
        self.fontService = fontService
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.primaryRendererLanguage.languageDirection.semanticContentAttribute
    }
    
    var title: String? {
        return callToActionModel?.text
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var titleTextAlignment: NSTextAlignment {
        
        switch pageModel.language.languageDirection {
        case .leftToRight:
            return .left
        case .rightToLeft:
            return .right
        }
    }
    
    var titleColor: UIColor {
        return callToActionModel?.getTextColor()?.color ?? pageModel.pageColors.textColor
    }
    
    var nextButtonColor: UIColor {
        return callToActionModel?.getControlColor()?.color ?? pageModel.pageColors.primaryColor
    }
    
    var nextButtonImage: UIImage? {
        
        guard let buttonImage = UIImage(named: "right_arrow_blue") else {
            return nil
        }
                        
        if languageDirectionSemanticContentAttribute == .forceLeftToRight {
            return buttonImage
        }
        
        return buttonImage.imageFlippedForRightToLeftLayoutDirection()
    }
    
    var nextButtonSemanticContentAttribute: UISemanticContentAttribute {
        return languageDirectionSemanticContentAttribute
    }
}
