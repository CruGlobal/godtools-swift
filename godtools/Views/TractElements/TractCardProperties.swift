//
//  TractCardProperties.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCardProperties: XMLNode {
    
    enum CardState {
        case open, preview, close, hidden, enable
    }
    
    var cardState = CardState.preview
    var cardNumber = 0
    var backgroundProperties = TractBackgroundProperties()
    
    override func loadCustomProperties(_ properties: [String: Any]) {
        self.backgroundProperties.load(properties)
    }
    
}
