//
//  UIButton+SetInsets.swift
//  godtools
//
//  Created by Robert Eldredge on 10/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

//found here: https://noahgilmore.com/blog/uibutton-padding/

enum IconGravity {
    case start
    case end
}

extension UIButton {
    
    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat, iconGravity: IconGravity) {
        
        switch iconGravity {
        
        case .start:
            
            contentEdgeInsets = UIEdgeInsets(
                top: contentPadding.top,
                left: contentPadding.left,
                bottom: contentPadding.bottom,
                right: contentPadding.right + imageTitlePadding
            )
            
            titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: imageTitlePadding,
                bottom: 0,
                right: -imageTitlePadding
            )
            
        case .end:
            
            contentEdgeInsets = UIEdgeInsets(
                top: contentPadding.top,
                left: contentPadding.left + imageTitlePadding,
                bottom: contentPadding.bottom,
                right: contentPadding.right
            )
            
            titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -imageTitlePadding,
                bottom: 0,
                right: imageTitlePadding
            )
        }
    }
}
