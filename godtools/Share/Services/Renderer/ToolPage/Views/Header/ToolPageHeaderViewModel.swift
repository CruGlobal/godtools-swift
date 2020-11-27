//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderViewModel {
    
    private let toolPageColors: ToolPageColors
    private let fontService: FontService
    private let language: LanguageModel
    
    let headerNumber: String?
    let headerTitle: String?
    let hidesHeader: Bool
    
    required init(pageNode: PageNode, toolPageColors: ToolPageColors, fontService: FontService, language: LanguageModel) {
        
        self.toolPageColors = toolPageColors
        self.fontService = fontService
        self.language = language
        
        let pageHeaderNumber: String? = pageNode.headerNode?.number
        let pageHeaderTitle: String? = pageNode.headerNode?.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        headerNumber = pageHeaderNumber
        headerTitle = pageHeaderTitle
        self.hidesHeader = hidesHeader
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.primaryColor
    }
    
    var headerNumberFont: UIFont {
        return fontService.getFont(size: 54, weight: .regular)
    }
    
    var headerNumberColor: UIColor {
        return toolPageColors.primaryTextColor
    }
    
    var headerNumberAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
    
    var headerTitleFont: UIFont {
        return fontService.getFont(size: 19, weight: .regular)
    }
    
    var headerTitleColor: UIColor {
        return toolPageColors.primaryTextColor
    }
    
    var headerTitleAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
}
