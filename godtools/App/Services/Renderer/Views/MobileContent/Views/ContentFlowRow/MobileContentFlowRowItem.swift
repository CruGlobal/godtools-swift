//
//  MobileContentFlowRowItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol MobileContentFlowRowItem: MobileContentView {
    
    var itemWidth: MobileContentViewWidth { get }
    var widthConstraint: NSLayoutConstraint? { get set }
    
    func setWidthConstraint(constant: CGFloat)
}

extension MobileContentFlowRowItem {
    
    func setWidthConstraint(constant: CGFloat) {
        
        if let widthConstraint = self.widthConstraint {
            removeConstraint(widthConstraint)
            self.widthConstraint = nil
        }
        
        widthConstraint = addWidthConstraint(constant: constant)
    }
}
