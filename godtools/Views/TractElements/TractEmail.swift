//
//  TractEmail.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractEmail: BaseTractElement {
    
    // MARK: - Object properties
    
    var properties = TractEmailProperties()
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    override func buildFrame() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: ",")
    }
    
    // MARK: - Helpers
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.load(properties)
    }

}
