//
//  TractHeaderProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractHeaderProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var backgroundColor: UIColor?
    
    override func defineProperties() {
        self.properties = ["backgroundColor"]
    }
    
    override func setupDefaultProperties() {
        self.textScale = 3
        self.textColor = .gtWhite
    }
    
    // MARK: - View Properties
    
    var includesNumber = false

}
