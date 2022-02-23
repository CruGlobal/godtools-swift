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
    
    private var mobileContentPageViewFactory: MobileContentPageViewFactory?
            
    required init(headerModel: Header, rendererPageModel: MobileContentRendererPageModel, translationsFileCache: TranslationsFileCache, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.headerModel = headerModel
        self.rendererPageModel = rendererPageModel
        
        for factory in rendererPageModel.pageViewFactories.factories {
            if let mobileContentPageViewFactory = factory as? MobileContentPageViewFactory {
                self.mobileContentPageViewFactory = mobileContentPageViewFactory
            }
        }
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return rendererPageModel.language.languageDirection.semanticContentAttribute
    }
    
    var backgroundColor: UIColor {
        return rendererPageModel.pageColors.primaryColor
    }
    
    func getNumber(numberLabel: UILabel) -> MobileContentTextView? {
        
        guard let numberTextModel = headerModel.number else {
            return nil
        }
        
        let numberLabelAttributes = MobileContentTextLabelAttributes(
            fontSize: 54,
            fontWeight: .regular,
            lineSpacing: nil,
            numberOfLines: 1
        )
        
        return mobileContentPageViewFactory?.getContentText(
            textModel: MultiplatformContentText(text: numberTextModel),
            rendererPageModel: rendererPageModel,
            viewType: .labelOnly(label: numberLabel, shouldAddLabelAsSubview: false),
            additionalLabelAttributes: numberLabelAttributes
        )
    }
    
    func getTitle(titleLabel: UILabel) -> MobileContentTextView? {
        
        guard let titleTextModel = headerModel.title else {
            return nil
        }
        
        let titleLabelAttributes = MobileContentTextLabelAttributes(
            fontSize: 19,
            fontWeight: .regular,
            lineSpacing: 2,
            numberOfLines: 0
        )
                
        return mobileContentPageViewFactory?.getContentText(
            textModel: MultiplatformContentText(text: titleTextModel),
            rendererPageModel: rendererPageModel,
            viewType: .labelOnly(label: titleLabel, shouldAddLabelAsSubview: false),
            additionalLabelAttributes: titleLabelAttributes
        )
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

