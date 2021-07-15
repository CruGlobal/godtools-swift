//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderViewModel: ToolPageHeaderViewModelType {
    
    private let headerModel: HeaderModelType
    private let pageModel: MobileContentRendererPageModel
    
    let trainingTipView: TrainingTipView?
    
    required init(headerModel: HeaderModelType, pageModel: MobileContentRendererPageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.headerModel = headerModel
        self.pageModel = pageModel
        
        var trainingTipView: TrainingTipView? = nil
        
        if let trainingTipId = headerModel.trainingTip {
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
        return pageModel.language.languageDirection.semanticContentAttribute
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

