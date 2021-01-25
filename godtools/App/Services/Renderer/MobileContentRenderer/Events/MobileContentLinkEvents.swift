//
//  MobileContentLinkEvents.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentLinkEvents {
    
    private let mobileContentEvents: MobileContentEvents
    private let mobileContentAnalytics: MobileContentAnalytics
    
    private var linkEvents: [UIButton: ContentLinkNode] = Dictionary()
    
    required init(mobileContentEvents: MobileContentEvents, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.mobileContentEvents = mobileContentEvents
        self.mobileContentAnalytics = mobileContentAnalytics
    }
    
    func removeAllLinkEvents() {
        
        let linkButtons: [UIButton] = Array(linkEvents.keys)
        
        for linkButton in linkButtons {
            linkButton.removeTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
        }
        
        linkEvents.removeAll()
    }
    
    func addLinkEvent(button: UIButton, linkNode: ContentLinkNode) {
        
        guard linkEvents[button] == nil else {
            return
        }
        
        linkEvents[button] = linkNode
        
        button.addTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
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
