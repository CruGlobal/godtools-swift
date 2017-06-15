//
//  TractTextContent+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractTextContent {
    
    func buildLabel() {
        let properties = textProperties()
        
        self.label = GTLabel(frame: getFrame())
        self.label.text = properties.value
        self.label.textAlignment = properties.textAlign
        self.label.font = properties.font
        self.label.textColor = properties.textColor
        self.label.lineBreakMode = .byWordWrapping
        
        if properties.height == 0.0 {
            self.label.numberOfLines = 0
            self.label.sizeToFit()
            properties.height = self.label.frame.size.height
            self.height = properties.height
        }
        
        let labelFrame = getFrame()
        self.label.frame = labelFrame
        updateFrameHeight()
        
        self.addSubview(self.label)
    }
    
}
