//
//  ToolPageCallToActionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageCallToActionViewModel: MobileContentViewModel {
    
    private let callToActionModel: CallToAction?
    private let fontService: FontService
        
    init(callToActionModel: CallToAction?, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.callToActionModel = callToActionModel
        self.fontService = fontService
        
        super.init(baseModel: callToActionModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return renderedPageContext.primaryRendererLanguage.direction.semanticContentAttribute
    }
    
    var title: String? {
        return callToActionModel?.label?.text
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var titleTextAlignment: NSTextAlignment {
        
        switch renderedPageContext.language.direction {
        case .leftToRight:
            return .left
        case .rightToLeft:
            return .right
        }
    }
    
    var titleColor: UIColor {
        return callToActionModel?.label?.textColor ?? renderedPageContext.pageModel.textColor
    }
    
    var nextButtonColor: UIColor {
        return callToActionModel?.controlColor ?? renderedPageContext.pageModel.primaryColor
    }
    
    var nextButtonImage: UIImage? {
        
        guard let buttonImage = ImageCatalog.rightArrowBlue.uiImage else {
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
