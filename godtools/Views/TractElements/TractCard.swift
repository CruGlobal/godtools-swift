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
    static let yBottomMarginConstant: CGFloat = 80.0
    static let xPaddingConstant: CGFloat = 28.0
    static let contentBottomPadding: CGFloat = 50.0
    
    // MARK: - Positions and Sizes
    
    var yDownPosition: CGFloat = 0.0
    
    var xPosition: CGFloat {
        return TractCard.xMarginConstant
    }
    
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractCard.xMarginConstant
    }
    
    var contentWidth: CGFloat {
        return self.width - (TractCard.shadowPaddingConstant * CGFloat(2))
    }
    
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
    
    var properties = TractCardProperties()
    var shadowView = UIView()
    let scrollView = UIScrollView()
    let containerView = UIView()
    var cardsParentView: TractCards {
        return self.parent as! TractCards
    }
    
    // MARK: - Setup
    
    override func setupView(properties: Dictionary<String, Any>) {
        super.setupView(properties: properties)
        
        loadElementProperties(properties)
        
        self.frame = buildFrame()
        
        setupStyle()
        setupScrollView()
        setBordersAndShadows()
        disableScrollview()
        setupSwipeGestures()
    }
    
    func setupStyle() {
        self.backgroundColor = .clear
        
        if self.properties.hidden {
            self.isHidden = true
            self.properties.cardState = .hidden
        }
    }
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: ",")
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.containerView.addSubview(element.render())
        }
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.shadowView)
        self.addSubview(self.scrollView)
        setupTransparentView()
        
        TractBindings.addBindings(self)
        return self
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = self.xPosition
        self.elementFrame.width = self.width
        self.elementFrame.height = self.externalHeight
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
    }

}
