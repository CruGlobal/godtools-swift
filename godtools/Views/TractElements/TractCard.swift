//
//  TractCard.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

//  NOTES ABOUT THE COMPONENT
//  * The height size of this component will always be the size of Cards.height minus the margins

class TractCard: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 8.0
    static let shadowPaddingConstant: CGFloat = 2.0
    static let yTopMarginConstant: CGFloat = 8.0
    static let yBottomMarginConstant: CGFloat = 120.0
    static let xPaddingConstant: CGFloat = 28.0
    static let contentBottomPadding: CGFloat = 50.0
    
    // MARK: - Positions and Sizes
    
    var yDownPosition: CGFloat = 0.0
    
    var externalHeight: CGFloat {
        return (self.parent?.height)! - TractCard.yTopMarginConstant - TractCard.yBottomMarginConstant
    }
    
    var internalHeight: CGFloat {
        let internalHeight = self.height > self.externalHeight ? self.height + TractCard.contentBottomPadding : self.externalHeight
        return internalHeight
    }
    
    var translationY: CGFloat {
        return self.externalHeight - self.elementFrame.y
    }
    
    // MARK: - Object properties
    
    var shadowView = UIView()
    let scrollView = UIScrollView()
    let backgroundView = UIView()
    let containerView = UIView()
    var cardsParentView: TractCards {
        return self.parent as! TractCards
    }
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCardProperties.self
    }
    
    override func loadStyles() {
        let properties = cardProperties()
        
        if properties.hidden {
            self.isHidden = true
            properties.cardState = .hidden
        }
        
        setupScrollView()
        setBordersAndShadows()
        disableScrollview()
        setupSwipeGestures()
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.containerView.addSubview(element.render())
        }
        
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.shadowView)
        self.addSubview(self.backgroundView)
        self.addSubview(self.scrollView)
        
        setupTransparentView()
        setupBackground()
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func elementListeners() -> [String]? {
        let properties = cardProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: ",")
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.xMargin = TractCard.xMarginConstant
    }
    
    override func updateFrameHeight() {
        self.height = cardHeight()
        super.updateFrameHeight()
    }
    
    // MARK: - Helpers
    
    func cardProperties() -> TractCardProperties {
        return self.properties as! TractCardProperties
    }
    
    func cardHeight() -> CGFloat {
        return self.getMaxHeight() - TractCard.yBottomMarginConstant
    }

}
