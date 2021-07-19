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
    private let rendererPageModel: MobileContentRendererPageModel
    private let fontService: FontService
        
    required init(callToActionModel: CallToActionModelType?, rendererPageModel: MobileContentRendererPageModel, fontService: FontService) {
        
        self.callToActionModel = callToActionModel
        self.rendererPageModel = rendererPageModel
        self.fontService = fontService
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return rendererPageModel.primaryRendererLanguage.languageDirection.semanticContentAttribute
    }
    
    var title: String? {
        return callToActionModel?.text
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var titleTextAlignment: NSTextAlignment {
        
        switch rendererPageModel.language.languageDirection {
        case .leftToRight:
            return .left
        case .rightToLeft:
            return .right
        }
    }
    
    var titleColor: UIColor {
        return callToActionModel?.getTextColor()?.uiColor ?? rendererPageModel.pageColors.textColor.uiColor
    }
    
    var nextButtonColor: UIColor {
        return callToActionModel?.getControlColor()?.uiColor ?? rendererPageModel.pageColors.primaryColor.uiColor
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
