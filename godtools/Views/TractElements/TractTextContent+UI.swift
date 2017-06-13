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
        self.label = GTLabel(frame: buildFrame())
        self.label.text = self.properties.value
        self.label.textAlignment = self.properties.textAlign
        self.label.font = self.properties.font
        self.label.textColor = self.properties.color
        self.label.lineBreakMode = .byWordWrapping
        
        if self.properties.height == 0.0 {
            self.label.numberOfLines = 0
            self.label.sizeToFit()
            self.height = self.label.frame.height
        } else {
            self.height = self.properties.height
        }
    }
    
}
