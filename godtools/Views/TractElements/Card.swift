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
    
    static let xMarginConstant = CGFloat(8.0)
    static let yTopMarginConstant = CGFloat(8.0)
    static let yBottomMarginConstant = CGFloat(80.0)
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    
    private var cardIsOpen: Bool = false
    var xPosition: CGFloat {
        return Card.xMarginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Card.xMarginConstant
    }
    override var height: CGFloat {
        get {
            return (self.parent?.height)! - Card.yTopMarginConstant - Card.yBottomMarginConstant
        }
        set {
            // Unused
        }
    }
    var translationY: CGFloat {
        return self.height - self.yStartPosition
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.backgroundColor = .green
        setupScrollView()
    }
    
    func setupScrollView() {
        let contentHeight = CGFloat(600.0) // TODO: set dynamic height
        self.scrollView.contentSize = CGSize(width: self.width, height: contentHeight)
        self.scrollView.frame = self.bounds
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: self.width,
                                          height: contentHeight)
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.containerView.addSubview(element.render())
        }
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.scrollView)
        return self
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Actions
    
    func changeCardState() {
        let cardsView = self.parent as! Cards
        if self.cardIsOpen {
            resetCard()
            cardsView.showCardsExcept(card: self)
        } else {
            slideUp()
            cardsView.hideCardsExcept(card: self)
        }
        self.cardIsOpen = !self.cardIsOpen
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
