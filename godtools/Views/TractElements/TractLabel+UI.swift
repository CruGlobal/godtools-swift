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
        let xPosition = TractCard.xPaddingConstant
        let yPosition = self.frame.size.height - 1
        let width = self.frame.size.width - (TractCard.xPaddingConstant * CGFloat(2))
        let height: CGFloat = 1.0
        
        let horizontalLine = UIView()
        horizontalLine.frame = CGRect(x: xPosition,
                                      y: yPosition,
                                      width: width,
                                      height: height)
        horizontalLine.backgroundColor = .gtGreyLight
        self.addSubview(horizontalLine)
        
    }
    
}
