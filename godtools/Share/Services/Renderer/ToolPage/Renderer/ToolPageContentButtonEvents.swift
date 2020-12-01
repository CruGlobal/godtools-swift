//
//  ToolPageContentButtonEvents.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentButtonEvents {
    
    private let mobileContentEvents: MobileContentEvents
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private var buttonEvents: [UIButton: ContentButtonNode] = Dictionary()
    
    required init(mobileContentEvents: MobileContentEvents, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.mobileContentEvents = mobileContentEvents
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func removeAllButtonEvents() {
        
        let buttons: [UIButton] = Array(buttonEvents.keys)
        
        for button in buttons {
            button.removeTarget(self, action: #selector(handleButtonTapped(button:)), for: .touchUpInside)
        }
        
        buttonEvents.removeAll()
    }
    
    func addButtonEvent(button: UIButton, buttonNode: ContentButtonNode) {
        
        guard buttonEvents[button] == nil else {
            return
        }
        
        buttonEvents[button] = buttonNode
        
        button.addTarget(self, action: #selector(handleButtonTapped(button:)), for: .touchUpInside)
    }
    
    func removeButtonEvent(button: UIButton) {
        
        guard buttonEvents[button] != nil else {
            return
        }
        
        buttonEvents[button] = nil
        
        button.removeTarget(self, action: #selector(handleButtonTapped(button:)), for: .touchUpInside)
    }
    
    @objc func handleButtonTapped(button: UIButton) {
        
        guard let buttonNode = buttonEvents[button] else {
            return
        }
        
        if buttonNode.type == "event" {
            
            let followUpSendEventName: String = "followup:send"
            
            if buttonNode.events.contains(followUpSendEventName) {
                var triggerEvents: [String] = buttonNode.events
                if let index = triggerEvents.firstIndex(of: followUpSendEventName) {
                    triggerEvents.remove(at: index)
                }
                mobileContentEvents.followUpEventButtonTapped(followUpEventButton: FollowUpButtonEvent(triggerEventsOnFollowUpSent: triggerEvents))
            }
            else {
                for event in buttonNode.events {
                    mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
                }
            }
        }
        else if buttonNode.type == "url", let url = buttonNode.url {
            mobileContentEvents.urlButtonTapped(urlButtonEvent: UrlButtonEvent(url: url))
        }
        
        if let analyticsEventsNode = buttonNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
