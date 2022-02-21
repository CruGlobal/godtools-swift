//
//  MobileContentNumberViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentNumberViewModel: MobileContentNumberViewModelType {
    
    private let numberModel: MultiplatformNumber
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(numberModel: MultiplatformNumber, rendererPageModel: MobileContentRendererPageModel) {
        
        self.numberModel = numberModel
        self.rendererPageModel = rendererPageModel
    }
    
    var fontSize: CGFloat {
        return 54
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        return rendererPageModel.pageColors.primaryTextColor
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentNumberViewModel: MobileContentViewModelType {
    
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
