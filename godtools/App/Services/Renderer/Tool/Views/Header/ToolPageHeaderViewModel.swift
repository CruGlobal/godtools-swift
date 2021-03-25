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
    private let fontService: FontService
    private let language: LanguageModel
    
    let hidesHeader: Bool
    let number: String?
    let title: String?
    let trainingTipViewModel: TrainingTipViewModelType?
    
    required init(headerNode: HeaderNode, pageModel: MobileContentRendererPageModel, fontService: FontService, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService, trainingTipsEnabled: Bool) {
        
        self.pageModel = pageModel
        self.fontService = fontService
        self.language = pageModel.language
        
        let pageHeaderNumber: String? = headerNode.number
        let pageHeaderTitle: String? = headerNode.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        self.hidesHeader = hidesHeader
        number = pageHeaderNumber
        title = pageHeaderTitle
        
        if trainingTipsEnabled, let trainingTipId = headerNode.trainingTip, !trainingTipId.isEmpty {
            
            trainingTipViewModel = TrainingTipViewModel(
                trainingTipId: trainingTipId,
                pageModel: pageModel,
                viewType: .upArrow,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService
            )
        }
        else {
            trainingTipViewModel = nil
        }
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
    
    var backgroundColor: UIColor {
        return pageModel.pageColors.primaryColor
    }
    
    var numberFont: UIFont {
        return fontService.getFont(size: 54, weight: .regular)
    }
    
    var numberColor: UIColor {
        return pageModel.pageColors.primaryTextColor
    }
    
    var numberAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 19, weight: .regular)
    }
    
    var titleColor: UIColor {
        return pageModel.pageColors.primaryTextColor
    }
    
    var titleAlignment: NSTextAlignment {
        return language.languageDirection == .leftToRight ? .left : .right
    }
}
