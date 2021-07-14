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
    private let pageModel: MobileContentRendererPageModel
    
    required init(titleModel: TitleModelType, pageModel: MobileContentRendererPageModel) {
        
        self.titleModel = titleModel
        self.pageModel = pageModel
    }
    
    var fontSize: CGFloat {
        return 19
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        return titleModel.getTextColor()?.color ?? pageModel.pageColors.primaryTextColor
    }
    
    var lineSpacing: CGFloat {
        return 2
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentTitleViewModel: MobileContentViewModelType {
    
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
