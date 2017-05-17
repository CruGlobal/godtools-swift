//
//  CallToActionAnimations.swift
//  godtools
//
//  Created by Devserker on 5/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractCallToAction {
    
    func showCallToAction() {
        let translationY = (self.parent?.maxHeight)! - self.yPosition - self.height
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: translationY) },
                       completion: nil )
    }
    
    func hideCallToAction() {
        UIView.animate(withDuration: 0.30,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: 0.0) },
                       completion: nil )
    }
    
}
