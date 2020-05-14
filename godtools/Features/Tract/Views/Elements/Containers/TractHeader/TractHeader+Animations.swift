//
//  TractHeaderAnimations.swift
//  godtools
//
//  Created by Devserker on 5/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractHeader {
    
    func showHeader(animated: Bool) {
        
        self.currentAnimation = .none
        let newTransform = CGAffineTransform(translationX: 0, y: 0.0)
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                //animations
                self?.transform = newTransform
            }, completion: nil)
        }
        else {
            transform = newTransform
        }
    }
    
    func hideHeader(animated: Bool) {
        
        self.currentAnimation = .hide
        let translationY = -elementFrame.y - height - 20
        let newTransform = CGAffineTransform(translationX: 0, y: translationY)
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                //animations
                self?.transform = newTransform
            }, completion: nil)
        }
        else {
            transform = newTransform
        }
    }
}
