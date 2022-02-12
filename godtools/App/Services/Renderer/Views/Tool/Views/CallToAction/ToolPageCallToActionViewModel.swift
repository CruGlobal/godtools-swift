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
    private let rendererPageModel: MobileContentRendererPageModel
    private let fontService: FontService
        
    required init(callToActionModel: CallToAction?, rendererPageModel: MobileContentRendererPageModel, fontService: FontService) {
        
        self.callToActionModel = callToActionModel
        self.rendererPageModel = rendererPageModel
        self.fontService = fontService
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return rendererPageModel.primaryRendererLanguage.languageDirection.semanticContentAttribute
    }
    
    var title: String? {
        return callToActionModel?.label?.text
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
        return callToActionModel?.label?.textColor ?? rendererPageModel.pageColors.textColor
    }
    
    var nextButtonColor: UIColor {
        return callToActionModel?.controlColor ?? rendererPageModel.pageColors.primaryColor
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
