//
//  TractRootActions.swift
//  godtools
//
//  Created by Devserker on 5/17/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractRoot {
    
    func showHeader() {
        for element in self.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! TractHeader
                header.showHeader()
                break
            }
        }
    }
    
    func hideHeader() {
        for element in self.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! TractHeader
                header.hideHeader()
                break
            }
        }
    }
    
    func showCallToAction() {
        for element in self.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! TractCallToAction
                callToAction.showCallToActionAnimation()
                break
            }
        }
    }
    
    func hideCallToAction() {
        for element in self.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! TractCallToAction
                callToAction.hideCallToActionAnimation()
                break
            }
        }
    }
    
    override func receiveMessage() {
        
        if self.properties.listeners == nil {
            return
        }
        
        for listener in self.properties.listeners!.components(separatedBy: ",") {
            NotificationCenter.default.post(name: .moveToPageNotification, object: nil, userInfo: ["pageListener": listener])
        }
    }
    
}
