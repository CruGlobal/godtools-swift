//
//  Card.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class Card: BaseTractElement {
    
    static let marginConstant = CGFloat(8.0)
    
    private var cardIsOpen: Bool = false
    var xPosition: CGFloat {
        return Card.marginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - Card.marginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.backgroundColor = .green
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Actions
    
    func changeCardState() {
        if self.cardIsOpen {
            slideDown()
        } else {
            slideUp()
        }
        self.cardIsOpen = !self.cardIsOpen
    }
    
    fileprivate func slideUp() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: -self.yPosition) },
                       completion: nil )
    }
    
    fileprivate func slideDown() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }

}
