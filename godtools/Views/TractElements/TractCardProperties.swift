//
//  TractCardProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCardProperties: TractProperties {
    
    enum CardState {
        case open, preview, close, hidden, enable
    }
    
    // MARK: - XML Properties
    
    var cardState = CardState.preview
    var cardNumber = 0
    
    // MARK: - View Properties
    
    var styleProperties = TractStyleProperties()
    
    // MARK: - Setup of custom properties
    
    override func loadCustomProperties(_ properties: [String: Any]) {
        self.styleProperties.load(properties)
    }
    
}
