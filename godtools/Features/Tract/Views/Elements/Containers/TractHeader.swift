//
//  TractHeader.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractHeader: BaseTractElement {
    
    enum HeaderAnimationState {
        case none, hide
    }
    
    var currentAnimation: TractHeader.HeaderAnimationState = .none
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractHeaderProperties.self
    }
    
    override func loadStyles() {
        guard let page = page else {
            return
        }
        
        let backgroundColor = page.pageProperties().primaryColor
        self.backgroundColor = backgroundColor
    }
    
    override func loadElementProperties(_ properties: [String : Any]) {
        super.loadElementProperties(properties)
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = 1.0
        self.elementFrame.yMarginBottom = 10.0
    }
    
    override var horizontalContainer: Bool {
        return true
    }
    
    override func loadParallelElementState() {
        guard let element = self.parallelElement else {
            return
        }
        
        let headerElement = element as! TractHeader
        switch headerElement.currentAnimation {
        case .hide:
            hideHeader(animated: false)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    func headerProperties() -> TractHeaderProperties {
        return self.properties as! TractHeaderProperties
    }
}

// MARK: - Animations

extension TractHeader {
    
    func showHeader(animated: Bool) {
        
        self.currentAnimation = .none
        let newTransform = CGAffineTransform(translationX: 0, y: 0.0)
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                //animations
                self?.transform = newTransform
            }, completion: nil)
        }
        else {
            transform = newTransform
        }
    }
    
    func hideHeader(animated: Bool) {
        
        self.currentAnimation = .hide
        let translationY = -elementFrame.y - height - 20
        let newTransform = CGAffineTransform(translationX: 0, y: translationY)
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                //animations
                self?.transform = newTransform
            }, completion: nil)
        }
        else {
            transform = newTransform
        }
    }
}
