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
    private let mobileContentEvents: MobileContentEvents
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat
    private let fontWeight: UIFont.Weight
    
    let titleColor: UIColor
    
    required init(linkNode: ContentLinkNode, mobileContentEvents: MobileContentEvents, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) {
        
        self.linkNode = linkNode
        self.mobileContentEvents = mobileContentEvents
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
    
    func linkTapped() {
    
        for event in linkNode.events {
            mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
        }
        
        if let analyticsEventsNode = linkNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
