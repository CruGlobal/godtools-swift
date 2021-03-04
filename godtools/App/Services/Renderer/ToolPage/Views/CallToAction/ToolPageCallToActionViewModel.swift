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
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let fontService: FontService
    
    let hidesCallToAction: Bool
    
    required init(callToActionNode: CallToActionNode?, heroNode: HeroNode?, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors, fontService: FontService, isLastPage: Bool) {
        
        self.callToActionNode = callToActionNode
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.fontService = fontService
        self.hidesCallToAction = (callToActionNode == nil && heroNode == nil) || isLastPage
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return diContainer.languageDirectionSemanticContentAttribute
    }
    
    var title: String? {
        return callToActionNode?.textNode?.text
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var titleColor: UIColor {
        return callToActionNode?.textNode?.getTextColor()?.color ?? toolPageColors.textColor
    }
    
    var nextButtonColor: UIColor {
        return callToActionNode?.getControlColor()?.color ?? toolPageColors.primaryColor
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
}
