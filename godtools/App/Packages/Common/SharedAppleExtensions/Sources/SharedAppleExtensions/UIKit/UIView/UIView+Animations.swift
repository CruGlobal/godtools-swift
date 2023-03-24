//
//  UIView+Animations.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

public extension UIView {
    
    func animateHidden(hidden: Bool, animated: Bool) {
        
        let alpha: CGFloat = hidden ? 0 : 1
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.alpha = alpha
            }, completion: nil)
        }
        else {
            self.alpha = alpha
        }
    }
}
