//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageHeaderViewModel: ToolPageHeaderViewModelType {
    
    private let headerModel: Header
    private let rendererPageModel: MobileContentRendererPageModel
        
    required init(headerModel: Header, rendererPageModel: MobileContentRendererPageModel, translationsFileCache: TranslationsFileCache, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.headerModel = headerModel
        self.rendererPageModel = rendererPageModel
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

