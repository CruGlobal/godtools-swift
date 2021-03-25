//
//  MobileContentTitleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTitleViewModel: MobileContentTitleViewModelType {
    
    private let titleNode: TitleNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(titleNode: TitleNode, pageModel: MobileContentRendererPageModel) {
        
        self.titleNode = titleNode
        self.pageModel = pageModel
    }
    
    var text: String? {
        return titleNode.textNode?.text
    }
    
    var fontSize: CGFloat {
        return 19
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        
        return titleNode.textNode?.getTextColor()?.color ?? pageModel.pageColors.primaryTextColor
    }
    
    var textAlignment: NSTextAlignment {
        return languageTextAlignment
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
