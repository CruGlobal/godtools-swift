//
//  UIScrollView+DisableScrollEdgeEffect.swift
//  godtools
//
//  Created by Levi Eggert on 9/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    @MainActor
    func disableScrollEdgeEffect() {
        
        if #available(iOS 26, *) {
            topEdgeEffect.isHidden = true
            bottomEdgeEffect.isHidden = true
            leftEdgeEffect.isHidden = true
            rightEdgeEffect.isHidden = true
        }
    }
}
