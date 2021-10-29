//
//  UIButton+SetInsets.swift
//  godtools
//
//  Created by Robert Eldredge on 10/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension UIButton {
    //found here: https://noahgilmore.com/blog/uibutton-padding/
    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat,
        iconGravity: IconGravity
    ) {
        switch iconGravity {
        case .start:
            self.contentEdgeInsets = UIEdgeInsets(
                top: contentPadding.top,
                left: contentPadding.left,
                bottom: contentPadding.bottom,
                right: contentPadding.right + imageTitlePadding
            )
            self.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: imageTitlePadding,
                bottom: 0,
                right: -imageTitlePadding
            )
            
        case .end:
            self.contentEdgeInsets = UIEdgeInsets(
                top: contentPadding.top,
                left: contentPadding.left + imageTitlePadding,
                bottom: contentPadding.bottom,
                right: contentPadding.right
            )
            self.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -imageTitlePadding,
                bottom: 0,
                right: imageTitlePadding
            )
        }
    }
}
