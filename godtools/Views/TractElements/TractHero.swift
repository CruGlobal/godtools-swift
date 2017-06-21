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
            let newHeight = maxHeight - (maxHeight - initialPosition)
            self.elementFrame.height = newHeight - 8
            self.frame = self.elementFrame.getFrame()
            self.backgroundColor = .blue
        }
    }
    
    // MARK: - Helpers
    
    func heroProperties() -> TractHeroProperties {
        return self.properties as! TractHeroProperties
    }
    
    func setupScrollView() {
        let width = self.elementFrame.finalWidth() - (TractCard.shadowPaddingConstant * CGFloat(2))
        let xPosition = (self.elementFrame.finalWidth() - width) / CGFloat(2)
        let height = self.bounds.size.height
        let scrollViewFrame = CGRect(x: xPosition, y: 0.0, width: width, height: height)
        
        self.scrollView.contentSize = CGSize(width: width, height: self.internalHeight)
        self.scrollView.frame = scrollViewFrame
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .clear
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.backgroundView.frame = scrollViewFrame
        
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: width,
                                          height: self.internalHeight)
        self.containerView.backgroundColor = .clear
    }
        
}
