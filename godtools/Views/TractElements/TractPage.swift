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
        self.properties.primaryColor = self.styleProperties?.primaryColor
        self.properties.primaryTextColor = self.styleProperties?.primaryTextColor
        self.properties.textColor = self.styleProperties?.textColor
        
        self.properties.load(properties)
        
        self.styleProperties?.primaryColor = self.properties.primaryColor!
        self.styleProperties?.primaryTextColor = self.properties.primaryTextColor!
        self.styleProperties?.textColor = self.properties.textColor!
    }
    
    override func buildFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: self.yStartPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func elementListeners() -> [String]? {
        return self.properties.listeners == nil ? nil : self.properties.listeners?.components(separatedBy: ",")
    }
    
}
