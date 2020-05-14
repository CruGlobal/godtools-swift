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
    
    func showCallToAction(animated: Bool) {
        
        currentAnimation = .show
        let bottomConstant: CGFloat = TractPage.statusbarHeight + TractPageContainer.marginBottom
        let translationY = parent!.getMaxHeight() - elementFrame.finalY() - height - bottomConstant
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
    
    func hideCallToAction(animated: Bool) {
        
        currentAnimation = .none
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
}
