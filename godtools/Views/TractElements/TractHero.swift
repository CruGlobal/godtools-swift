//
//  TractHero.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractHero: BaseTractElement {
    
    static let marginBottom: CGFloat = 8.0
    static let paddingBottom: CGFloat = 24.0
    static let horizontalMargin: CGFloat = 32.0
    
    // MARK: - Setup
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    var heroHeight: CGFloat = 0.0
    
    override func propertiesKind() -> TractProperties.Type {
        return TractHeroProperties.self
    }
    
    override func loadFrameProperties() {
        let width: CGFloat = parentWidth() - (2 * TractHero.horizontalMargin)
        
        self.elementFrame.x = (parentWidth() - width) / CGFloat(2)
        self.elementFrame.width = width
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
    }
    
    // MARK: The Hero size depends on how much text is needed to be displayed. This mainly affects how the scrollview is sized and whether or not there needs to be a CallToAction button at the bottom of the screen.
    
    override func render() -> UIView {
        if let followingElement = getFollowingElement() as? TractCards {
            updateHeroHeight(cards: followingElement)
        } else if let _ = getFollowingElement() as? TractCallToAction {
            let callToActionHeight = TractCallToAction.minHeight
            let callToActionPadding = TractCallToAction.paddingConstant
            updateHeroHeightWithNoCards(extraPadding: callToActionHeight + callToActionPadding)
        } else {
            updateHeroHeightWithNoCards()
        }
        
        setupScrollView()
        guard let elements = self.elements else {
            let blankView = UIView()
            blankView.isHidden = true
            return blankView
        }
        for element in elements {
            self.containerView.addSubview(element.render())
        }
        
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.scrollView)
        
        TractBindings.addBindings(self)
        return self
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
        
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: contentWidth,
                                          height: contentHeight)
        self.containerView.backgroundColor = .clear
    }
    
    func updateHeroHeight(cards: TractCards) {
        var height = cards.getMaxFreeHeight(hero: self)
        height -= (UIDevice.current.iPhoneWithNotch()) ? TractPage.navbarHeight + 28 /* correction factor */ : 0.0
        
        self.heroHeight = height
        self.elementFrame.height = self.heroHeight
        self.frame = self.elementFrame.getFrame()
    }
    
    func updateHeroHeightWithNoCards(extraPadding: CGFloat = 0) {
        self.heroHeight = BaseTractElement.screenHeight - TractHero.paddingBottom - extraPadding
        self.elementFrame.height = self.heroHeight
        self.frame = self.elementFrame.getFrame()
    }
    
}
