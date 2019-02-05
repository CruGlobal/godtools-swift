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
    
    @objc var subject: String = ""
    @objc var content: String = ""
    @objc var html: Bool = true
    @objc var listeners: String = ""
    
    override func defineProperties() {
        self.properties = ["subject", "content", "html", "listeners"]
    }
    
}
