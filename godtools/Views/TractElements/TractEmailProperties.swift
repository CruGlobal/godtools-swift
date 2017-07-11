//
//  TractEmailProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractEmailProperties: TractProperties {
    
    // MARK: - XML Properties
    
    var subject: String = ""
    var content: String = ""
    var html: Bool = true
    var listeners: String = ""
    
    override func defineProperties() {
        self.properties = ["subject", "content", "html", "listeners"]
    }
    
}
