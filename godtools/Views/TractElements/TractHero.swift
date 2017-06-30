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
    
    static let marginBottom: CGFloat = 8.0
    static let paddingBottom: CGFloat = 24.0
    
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
        let followingElement = getFollowingElement()
        if followingElement != nil && followingElement!.isKind(of: TractCards.self) {
            updateHeroHeight()
            setupScrollView()
            
            for element in self.elements! {
                self.containerView.addSubview(element.render())
            }
            
            self.scrollView.addSubview(self.containerView)
            self.addSubview(self.scrollView)
            
            TractBindings.addBindings(self)
            return self
        } else {
            return super.render()
        }
    }
    
    // MARK: - Helpers
    
    func heroProperties() -> TractHeroProperties {
        return self.properties as! TractHeroProperties
    }
    
    func setupScrollView() {
        let contentHeight: CGFloat = self.height + TractHero.paddingBottom
        let contentWidth: CGFloat = self.elementFrame.width
        
        self.scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        self.scrollView.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: self.heroHeight)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.backgroundColor = .red
        
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: contentWidth,
                                          height: contentHeight)
        self.containerView.backgroundColor = .clear
    }
    
    func updateHeroHeight() {
        let element = getFollowingElement()
        if element != nil && element!.isKind(of: TractCards.self) {
            let cardsElement = element as! TractCards
            self.heroHeight = cardsElement.getMaxHeroHeight()
            self.elementFrame.height = self.heroHeight
            self.frame = self.elementFrame.getFrame()
        }
    }
        
}
