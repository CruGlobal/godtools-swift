//
//  TractPage.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

//  NOTES ABOUT THE COMPONENT
//  * This component must always be initialized with: init(data: XMLIndexer, withMaxHeight height: CGFloat)

class TractPage: BaseTractElement {
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractPageProperties.self
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    override func elementListeners() -> [String]? {
        let properties = pageProperties()
        return properties.listeners == nil ? nil : properties.listeners?.components(separatedBy: ",")
    }
    
    // MARK: - Helpers
    
    func pageProperties() -> TractPageProperties {
        return self.properties as! TractPageProperties
    }
    
}
