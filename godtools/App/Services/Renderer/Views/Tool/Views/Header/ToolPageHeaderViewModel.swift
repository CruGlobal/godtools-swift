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
    private let rendererPageModel: MobileContentRendererPageModel
    
    let trainingTipView: TrainingTipView?
    
    required init(headerModel: HeaderModelType, rendererPageModel: MobileContentRendererPageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.headerModel = headerModel
        self.rendererPageModel = rendererPageModel
        
        var trainingTipView: TrainingTipView? = nil
        
        if let trainingTipId = headerModel.trainingTip {
            for pageViewFactory in rendererPageModel.pageViewFactories {
                if let trainingViewFactory = pageViewFactory as? TrainingViewFactory {
                    trainingTipView = trainingViewFactory.getTrainingTipView(
                        trainingTipId: trainingTipId,
                        rendererPageModel: rendererPageModel,
                        trainingTipViewType: .upArrow
                    )
                }
            }
        }
        
        self.trainingTipView = trainingTipView
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return rendererPageModel.language.languageDirection.semanticContentAttribute
    }
    
    var backgroundColor: UIColor {
        return rendererPageModel.pageColors.primaryColor
    }
}

// MARK: - MobileContentViewModelType

extension ToolPageHeaderViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return rendererPageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return []
    }
    
    var defaultAnalyticsEventsTrigger: MobileContentAnalyticsEventTrigger {
        return .visible
    }
}

