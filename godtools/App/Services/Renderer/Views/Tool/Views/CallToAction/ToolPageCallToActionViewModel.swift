//
//  ToolPageCallToActionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageCallToActionViewModel: ToolPageCallToActionViewModelType {
    
    private let callToActionModel: CallToAction?
    private let renderedPageContext: MobileContentRenderedPageContext
    private let fontService: FontService
        
    required init(callToActionModel: CallToAction?, renderedPageContext: MobileContentRenderedPageContext, fontService: FontService) {
        
        self.callToActionModel = callToActionModel
        self.renderedPageContext = renderedPageContext
        self.fontService = fontService
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return renderedPageContext.primaryRendererLanguage.languageDirection.semanticContentAttribute
    }
    
    var title: String? {
        return callToActionModel?.label?.text
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var titleTextAlignment: NSTextAlignment {
        
        switch renderedPageContext.language.languageDirection {
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
