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
    
    let trainingTipView: TrainingTipView?
    
    required init(headerNode: HeaderNode, pageModel: MobileContentRendererPageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.pageModel = pageModel
        
        var trainingTipView: TrainingTipView? = nil
        
        if let trainingTipId = headerNode.trainingTip {
            for pageViewFactory in pageModel.pageViewFactories {
                if let trainingViewFactory = pageViewFactory as? TrainingViewFactory {
                    trainingTipView = trainingViewFactory.getTrainingTipView(
                        trainingTipId: trainingTipId,
                        pageModel: pageModel,
                        trainingTipViewType: .upArrow
                    )
                }
            }
        }
        
        self.trainingTipView = trainingTipView
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

