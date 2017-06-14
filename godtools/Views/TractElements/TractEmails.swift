//
//  TractEmails.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractEmails: BaseTractElement {
    
    // MARK: - Setup
    
    var properties = TractEmailsProperties()
    
    override func loadStyles() {
        self.isHidden = true
    }
    
    override func render() -> UIView {
        TractBindings.addBindings(self)
        return self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
        self.properties.parentProperties = getParentProperties()
    }
    
    override func getElementProperties() -> TractProperties {
        return self.properties
    }

}
