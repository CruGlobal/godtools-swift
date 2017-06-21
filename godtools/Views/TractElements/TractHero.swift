//
//  TractHero.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractHero: BaseTractElement {
    
    // MARK: - Setup
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    var heroHeight: CGFloat = 0.0
    
    override func propertiesKind() -> TractProperties.Type {
        return TractHeroProperties.self
    }
    
    override func loadFrameProperties() {
        let width: CGFloat = 300
        self.elementFrame.x = (parentWidth() - width) / CGFloat(2)
        self.elementFrame.width = width
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
    }
    
    override func render() -> UIView {
        updateHeroHeight()
        setupScrollView()
        
        for element in self.elements! {
            self.containerView.addSubview(element.render())
        }
        
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.scrollView)
        
        TractBindings.addBindings(self)
        return self
    }
    
    func updateHeroHeight() {
        let element = getFollowingElement()
        if element != nil && element!.isKind(of: TractCards.self) {
            let cardsElement = element as! TractCards
            let initialPosition = cardsElement.elementFrame.y + (cardsElement.elements?[0].elementFrame.y)!
            let maxHeight = BaseTractElement.screenHeight
            self.heroHeight = maxHeight - (maxHeight - initialPosition) - 8
            self.elementFrame.height = self.heroHeight
            self.frame = self.elementFrame.getFrame()
        }
    }
    
    // MARK: - Helpers
    
    func heroProperties() -> TractHeroProperties {
        return self.properties as! TractHeroProperties
    }
    
    func setupScrollView() {
        self.scrollView.contentSize = CGSize(width: self.elementFrame.width, height: self.height)
        self.scrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.elementFrame.width, height: self.heroHeight)
        self.scrollView.backgroundColor = .clear
        
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: self.elementFrame.width,
                                          height: self.height)
        self.containerView.backgroundColor = .clear
    }
        
}
