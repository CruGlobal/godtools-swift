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
        self.properties.styleProperties.overrideProperties(withProperties: self.styleProperties!)
        self.properties.load(properties)
        self.styleProperties?.overrideProperties(withProperties: self.properties.styleProperties)
    }
    
    func loadFrameProperties() {
        self.properties.frame.x = 0.0
        self.properties.frame.y = self.yStartPosition
        self.properties.frame.width = self.width
        self.properties.frame.height = self.height
    }
    
    override func buildFrame() -> CGRect {
        return self.properties.frame.getFrame()
    }
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: ",")
    }
    
}
