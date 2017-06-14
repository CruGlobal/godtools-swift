//
//  TractModalProperties.swift
//  godtools
//
//  Created by Devserker on 5/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractModalProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var listeners: String?
    var dismissListeners: String?
    
    override func properties() -> [String]? {
        return ["listeners", "dismissListeners"]
    }
    
    // MARK: - View Properties
    
    var alreadyRendered = false
    
}
