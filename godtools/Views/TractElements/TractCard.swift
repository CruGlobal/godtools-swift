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
    
    // MARK: - Configurations
    
    enum CardState {
        case open, preview, close, hidden, enable
    }
    
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
    
    var yPosition: CGFloat {
        return self.yStartPosition
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
        return self.externalHeight - self.yStartPosition
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.externalHeight
    }
    
    // MARK: - Object properties
    
    var properties = TractCardProperties()
    var shadowView = UIView()
    let scrollView = UIScrollView()
    let containerView = UIView()
    var cardState = CardState.preview
    var cardNumber = 0
    var cardsParentView: TractCards {
        return self.parent as! TractCards
    }
    
    // MARK: - Setup
    
    override func setupView(properties: Dictionary<String, Any>) {
        loadElementProperties(properties: properties)
        
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
            self.cardState = .hidden
        }
    }
    
    override func elementListeners() -> [String]? {
        return self.properties.listener == nil ? nil : self.properties.listener?.components(separatedBy: ",")
    }
    
    func setupScrollView() {
        let height = self.bounds.size.height
        let scrollViewFrame = CGRect(x: 0.0, y: 0.0, width: self.contentWidth, height: height)
        
        let contentHeight = self.internalHeight
        self.scrollView.contentSize = CGSize(width: self.contentWidth, height: contentHeight)
        self.scrollView.frame = scrollViewFrame
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .gtWhite
        self.scrollView.showsVerticalScrollIndicator = false
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: self.contentWidth,
                                          height: contentHeight)
        self.containerView.backgroundColor = .clear
    }
    
    func setupTransparentView() {
        if self.externalHeight >= self.internalHeight {
            return
        }
        
        let width = self.scrollView.frame.size.width - 6.0
        let height: CGFloat = 60.0
        let xPosition: CGFloat = 3.0
        let yPosition = self.scrollView.frame.size.height - height - 1.0
        let transparentViewFrame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let transparentView = UIView(frame: transparentViewFrame)
        transparentView.backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = transparentView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        transparentView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.addSubview(transparentView)
    }
    
    func setBordersAndShadows() {
        self.shadowView.frame = self.bounds
        self.shadowView.backgroundColor = .white
        let shadowLayer = self.shadowView.layer
        shadowLayer.cornerRadius = 3.0
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowRadius = 3.0
        shadowLayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shouldRasterize = true
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
    
    // MARK: - Actions
    
    func didTapOnCard() {
        processCardWithState()
    }
    
    // MARK: - Helpers
    
    func loadElementProperties(properties: [String: Any]) {
        for property in properties.keys {
            switch property {
            case "hidden":
                self.properties.hidden = true
            case "listener":
                self.properties.listener = properties[property] as! String?
            default: break
            }
        }
    }
    
    func disableScrollview() {
        if self.cardState != .open {
            let startPoint = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
            self.scrollView.isScrollEnabled = false
            self.scrollView.setContentOffset(startPoint, animated: true)
        }
    }
    
    func enableScrollview() {
        if self.cardState == .open {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.externalHeight)
    }

}
