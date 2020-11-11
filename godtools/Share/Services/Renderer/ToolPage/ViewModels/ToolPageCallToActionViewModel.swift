//
//  ToolPageCallToActionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCallToActionViewModel {
    
    private let pageNode: PageNode
    private let toolPageColors: ToolPageColorsViewModel
    private let fontService: FontService

    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode, toolPageColors: ToolPageColorsViewModel, fontService: FontService, isLastPage: Bool) {
        
        self.pageNode = pageNode
        self.toolPageColors = toolPageColors
        self.fontService = fontService
        
        hidesCallToAction = (pageNode.callToActionNode == nil && pageNode.heroNode == nil) || isLastPage
    }
    
    var callToActionTitle: String? {
        return pageNode.callToActionNode?.textNode?.text
    }
    
    var callToActionTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var callToActionTitleColor: UIColor {
        return pageNode.callToActionNode?.textNode?.getTextColor()?.color ?? toolPageColors.textColor
    }
    
    var callToActionNextButtonColor: UIColor {
        return pageNode.callToActionNode?.getControlColor()?.color ?? toolPageColors.primaryColor
    }
}
