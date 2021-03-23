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
    private let fontSize: CGFloat
    private let fontWeight: UIFont.Weight
    
    let titleColor: UIColor
    
    required init(linkNode: ContentLinkNode, pageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) {
        
        self.linkNode = linkNode
        self.pageModel = pageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.titleColor = titleColor
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
    
        // TODO: Process events. ~Levi
        
        for event in linkNode.events {
            //mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
        }
        
        if let analyticsEventsNode = linkNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
