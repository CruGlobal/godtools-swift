//
//  MobileContentTitleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTitleViewModel: MobileContentTitleViewModelType {
    
    private let titleModel: TitleModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(titleModel: TitleModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.titleModel = titleModel
        self.rendererPageModel = rendererPageModel
    }
    
    var fontSize: CGFloat {
        return 19
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        return titleModel.getTextColor()
    }
    
    var lineSpacing: CGFloat {
        return 2
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentTitleViewModel: MobileContentViewModelType {
    
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
