//
//  ToolPageRenderedContent.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageRenderedContent {
    
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    
    private(set) var buttonEvents: [UIButton: ContentButtonNode] = Dictionary()
    private(set) var linkEvents: [UIButton: ContentLinkNode] = Dictionary()
    private(set) var hiddenInputNodes: [ContentInputNode] = Array()
    private(set) var inputViewModels: [ToolPageContentInputViewModelType] = Array()
    
    let containsTips: ObservableValue<Bool> = ObservableValue(value: false)
        
    required init(mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents) {
        
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
    }
    
    // MARK: - Button Events
    
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
    
    // MARK: - Link Events
    
    func addLinkEvent(button: UIButton, linkNode: ContentLinkNode) {
        
        guard linkEvents[button] == nil else {
            return
        }
        
        linkEvents[button] = linkNode
        
        button.addTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
    }
    
    func removeLinkEvent(button: UIButton) {
        
        guard linkEvents[button] != nil else {
            return
        }
        
        linkEvents[button] = nil
        
        button.removeTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
    }
    
    @objc func handleLinkTapped(button: UIButton) {
        
        guard let linkNode = linkEvents[button] else {
            return
        }
        
        for event in linkNode.events {
            mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
        }
        
        if let analyticsEventsNode = linkNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
