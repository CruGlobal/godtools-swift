//
//  TractPageActions.swift
//  godtools
//
//  Created by Devserker on 5/17/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractPage {
    
    func showHeader() {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! TractHeader
                header.showHeader(animated: true)
                break
            }
        }
    }
    
    func hideHeader() {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! TractHeader
                header.hideHeader(animated: true)
                break
            }
        }
    }
    
    func showCallToAction(animated: Bool = true) {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! TractCallToAction
                callToAction.showCallToAction(animated: animated)
                break
            }
        }
    }
    
    func hideCallToAction() {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! TractCallToAction
                callToAction.hideCallToAction(animated: true)
                break
            }
        }
    }
    
}
