//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentLinkViewModel: MobileContentLinkViewModelType {
    
    private let linkNode: ContentLinkNode
    private let pageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let titleColor: UIColor
    
    required init(linkNode: ContentLinkNode, pageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.linkNode = linkNode
        self.pageModel = pageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.titleColor = linkNode.textNode?.getTextColor()?.color ?? pageModel.pageColors.primaryColor
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkNode.textNode?.text
    }
    
    var linkEvents: [String] {
        return linkNode.events
    }
    
    func linkTapped() {
        if let analyticsEventsNode = linkNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode, page: pageModel)
        }
    }
}
