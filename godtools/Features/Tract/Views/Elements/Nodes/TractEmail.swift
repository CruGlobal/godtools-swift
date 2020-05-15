//
//  TractEmail.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractEmail: BaseTractElement {
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractEmailProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        TractBindings.addBindings(self)
    }
    
    // MARK: - Bindings
    
   override func elementListeners() -> [String]? {
        let properties = emailProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: ",")
    }
    
    // MARK: - Helpers
    
    func emailProperties() -> TractEmailProperties {
        return self.properties as! TractEmailProperties
    }
}

// MARK: - Actions

extension TractEmail {
    
    override func receiveMessage() {
        let properties = emailProperties()
        let userInfo = ["subject": properties.subject, "content": properties.content, "html": properties.html] as [String : Any]
        NotificationCenter.default.post(name: .sendEmailFromTractForm, object: nil, userInfo: userInfo)
    }
}
