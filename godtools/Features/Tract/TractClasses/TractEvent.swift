//
//  TractEvent.swift
//  godtools
//
//  Created by Greg Weiss on 5/7/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class TractEvent: BaseTractElement {
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractEventProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    // MARK: - Bindings
    
    override func elementListeners() -> [String]? {
        return nil
    }
    
    // MARK: - Helpers
    
    func eventProperties() -> TractEventProperties {
        return self.properties as! TractEventProperties
    }
    
}
