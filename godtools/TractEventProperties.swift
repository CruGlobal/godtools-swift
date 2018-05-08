//
//  TractEventProperties.swift
//  godtools
//
//  Created by Greg Weiss on 5/7/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class TractEventProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var subject: String = ""
    var content: String = ""
    var html: Bool = true
    var listeners: String = ""
    
    override func defineProperties() {
        self.properties = []
    }
    
}
