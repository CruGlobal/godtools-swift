//
//  MobileContentButtonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentButtonViewModel: MobileContentButtonViewModelType {
    
    private let buttonNode: ContentButtonNode
    private let pageModel: MobileContentRendererPageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat
    private let fontWeight: UIFont.Weight
    
    let backgroundColor: UIColor
    let titleColor: UIColor
    let borderColor: CGColor?
    
    required init(buttonNode: ContentButtonNode, pageModel: MobileContentRendererPageModel, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, fontSize: CGFloat, fontWeight: UIFont.Weight, defaultBackgroundColor: UIColor, defaultTitleColor: UIColor, defaultBorderColor: UIColor?) {
        
        self.buttonNode = buttonNode
        self.pageModel = pageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        
        switch buttonNode.buttonStyle {
        
        case .contained:
            backgroundColor = defaultBackgroundColor
            titleColor = defaultTitleColor
            borderColor = defaultBorderColor?.cgColor
        case .outlined:
            backgroundColor = buttonNode.getBackgroundColor()?.color ?? .clear
            titleColor = defaultBackgroundColor
            borderColor = defaultBackgroundColor.cgColor
        }
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return buttonNode.textNode?.text
    }
    
    var borderWidth: CGFloat? {
        if borderColor == nil {
            return nil
        }
        return 1
    }
    
    func buttonTapped() {
        
        // TODO: Process button event. ~Levi
        
        if buttonNode.type == "event" {
            
            let followUpSendEventName: String = "followup:send"
            
            if buttonNode.events.contains(followUpSendEventName) {
                var triggerEvents: [String] = buttonNode.events
                if let index = triggerEvents.firstIndex(of: followUpSendEventName) {
                    triggerEvents.remove(at: index)
                }
                //mobileContentEvents.followUpEventButtonTapped(followUpEventButton: FollowUpButtonEvent(triggerEventsOnFollowUpSent: triggerEvents))
            }
            else {
                for event in buttonNode.events {
                    //mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
                }
            }
        }
        else if buttonNode.type == "url", let url = buttonNode.url {
            //mobileContentEvents.urlButtonTapped(urlButtonEvent: UrlButtonEvent(url: url))
        }
        
        if let analyticsEventsNode = buttonNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
