//
//  TractLabel+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractLabel {
    
    func buildHorizontalLine() {
        let height: CGFloat = 1.0
        let yPosition = self.frame.size.height - height
        let horizontalLine = UIView()
        horizontalLine.frame = CGRect(x: 0.0,
                                      y: yPosition,
                                      width: self.elementFrame.finalWidth(),
                                      height: height)
        horizontalLine.backgroundColor = .gtGreyLight
        self.addSubview(horizontalLine)
        
    }
    
}
