//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderViewModel: ToolPageHeaderViewModelType {
    
    private let pageModel: MobileContentRendererPageModel
    private let toolPageColors: ToolPageColors
    private let fontService: FontService
    private let language: LanguageModel
    
    let hidesHeader: Bool
    let number: String?
    let title: String?
    
    required init(headerNode: HeaderNode, pageModel: MobileContentRendererPageModel, toolPageColors: ToolPageColors, fontService: FontService) {
        
        self.pageModel = pageModel
        self.toolPageColors = toolPageColors
        self.fontService = fontService
        self.language = pageModel.language
        
        let pageHeaderNumber: String? = headerNode.number
        let pageHeaderTitle: String? = headerNode.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        self.hidesHeader = hidesHeader
        number = pageHeaderNumber
        title = pageHeaderTitle
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.primaryColor
    }
    
    var numberFont: UIFont {
        return fontService.getFont(size: 54, weight: .regular)
    }
    
    var numberColor: UIColor {
        return toolPageColors.primaryTextColor
    }
    
    var numberAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 19, weight: .regular)
    }
    
    var titleColor: UIColor {
        return toolPageColors.primaryTextColor
    }
    
    var titleAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
}
