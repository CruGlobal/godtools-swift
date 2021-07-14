//
//  MobileContentNumberViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentNumberViewModel: MobileContentNumberViewModelType {
    
    private let numberModel: NumberModelType
    private let pageModel: MobileContentRendererPageModel
    
    required init(numberModel: NumberModelType, pageModel: MobileContentRendererPageModel) {
        
        self.numberModel = numberModel
        self.pageModel = pageModel
    }
    
    var fontSize: CGFloat {
        return 54
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        return pageModel.pageColors.primaryTextColor
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentNumberViewModel: MobileContentViewModelType {
    
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
