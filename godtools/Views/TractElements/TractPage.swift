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
    
    // MARK: - Object properties
    
    var properties = TractPageProperties()
    
    // MARK: - Setup
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.styleProperties.loadPropertiesFromObject(self.styleProperties!)
        self.properties.load(properties)
        self.styleProperties?.loadPropertiesFromObject(self.properties.styleProperties)
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: ",")
    }
    
}
