//
//  CardAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension Card {
    
    func slideUp() {
        let translationY = Card.yTopMarginConstant - self.yPosition
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
    func resetCard() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
    func hideCard() {
        let translationY = self.height
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
}
