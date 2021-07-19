//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentLinkViewModel: MobileContentLinkViewModelType {
    
    private let linkModel: ContentLinkModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let titleColor: UIColor
    
    required init(linkModel: ContentLinkModelType, rendererPageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.linkModel = linkModel
        self.rendererPageModel = rendererPageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.titleColor = linkModel.getTextColor()?.color ?? rendererPageModel.pageColors.primaryColor
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkModel.text
    }
    
    var linkEvents: [String] {
        return linkModel.events
    }
    
    func linkTapped() {
        mobileContentAnalytics.trackEvents(events: linkModel.getAnalyticsEvents(), rendererPageModel: rendererPageModel)
    }
}
