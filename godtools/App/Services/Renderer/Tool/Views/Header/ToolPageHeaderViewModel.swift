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
    
    let trainingTipViewModel: TrainingTipViewModelType?
    
    required init(headerNode: HeaderNode, pageModel: MobileContentRendererPageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService, trainingTipsEnabled: Bool) {
        
        self.pageModel = pageModel
        
        // TODO: Can I fetch this from renderer?
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
}

// MARK: - MobileContentViewModelType

extension ToolPageHeaderViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return pageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return []
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}

