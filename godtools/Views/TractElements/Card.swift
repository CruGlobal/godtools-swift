//
//  Card.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

//  NOTES ABOUT THE COMPONENT
//  * The height size of this component will always be the size of Cards.height minus the margins

class Card: BaseTractElement {
    
    enum CardState {
        case open, preview, close
    }
    
    static let xMarginConstant = CGFloat(8.0)
    static let yTopMarginConstant = CGFloat(8.0)
    static let yBottomMarginConstant = CGFloat(80.0)
    static let xPaddingConstant = CGFloat(28.0)
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    var shadowView = UIView()
    
    var cardsParentView: Cards {
        return self.parent as! Cards
    }
    var cardState = CardState.preview
    var cardNumber = 0
    
    var yDownPosition = CGFloat(0.0)
    var xPosition: CGFloat {
        return Card.xMarginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Card.xMarginConstant
    }
    var externalHeight: CGFloat {
        return (self.parent?.height)! - Card.yTopMarginConstant - Card.yBottomMarginConstant
    }
    var internalHeight: CGFloat {
        return self.height > self.externalHeight ? self.height : self.externalHeight
    }
    var translationY: CGFloat {
        return self.externalHeight - self.yStartPosition
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        setupStyle()
        setupScrollView()
        setBordersAndShadows()
        disableScrollview()
        setupSwipeGestures()
    }
    
    func setupStyle() {
        self.backgroundColor = .clear
    }
    
    func setupScrollView() {
        let contentHeight = self.internalHeight
        self.scrollView.contentSize = CGSize(width: self.width, height: contentHeight)
        self.scrollView.frame = self.bounds
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .gtWhite
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: self.width,
                                          height: contentHeight)
    }
    
    func setBordersAndShadows() {
        let layer = self.scrollView.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.gtGreyLight.cgColor
        
        self.shadowView.frame = self.bounds
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
        return self
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.externalHeight
    }
    
    // MARK: - Actions
    
    func didTapOnCard() {
        switch self.cardState {
        case .preview:
            showCard()
        case .open:
            hideCard()
        case .close:
            showCard()
        }
    }
    
    // MARK: - Helpers
    
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
