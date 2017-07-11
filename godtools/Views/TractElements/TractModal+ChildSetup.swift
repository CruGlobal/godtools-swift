//
//  TractModal+SetupChildren.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractModal {
    
    func renderModalElements() {
        let properties = modalProperties()
        let modalHeight = BaseTractElement.screenHeight
        var startYPosition:CGFloat = 0
        
        if properties.alreadyRendered == false {
            startYPosition = (modalHeight - self.height) / CGFloat(2)
            properties.alreadyRendered = true
        }
        
        for element in self.elements! {
            element.removeFromSuperview()
            
            let xPosition = element.frame.origin.x
            let yPosition = element.frame.origin.y + startYPosition
            let width = element.frame.size.width
            let height = element.frame.size.height
            element.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            self.addSubview(element.render())
        }
    }
    
}
