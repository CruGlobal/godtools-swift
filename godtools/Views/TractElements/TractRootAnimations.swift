//
//  TractRootAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractRoot {
    
    func showHeader() {
        for element in self.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! Header
                header.showHeader()
                break
            }
        }
    }
    
    func hideHeader() {
        for element in self.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! Header
                header.hideHeader()
                break
            }
        }
    }
    
    func showCallToAction() {
        for element in self.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! CallToAction
                callToAction.showCallToAction()
                break
            }
        }
    }
    
    func hideCallToAction() {
        for element in self.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! CallToAction
                callToAction.hideCallToAction()
                break
            }
        }
    }
    
}
