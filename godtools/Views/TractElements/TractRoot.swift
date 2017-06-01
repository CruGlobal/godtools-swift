//
//  TractRoot.swift
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

class TractRoot: BaseTractElement {
    
    var pageId: String = ""
    
    // MARK: - Object properties
    
    var properties = TractRootProperties()
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        self.pageId = properties["id"] as? String ?? ""
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        self.properties.primaryColor = self.colors?.primaryColor
        self.properties.primaryTextColor = self.colors?.primaryTextColor
        self.properties.textColor = self.colors?.textColor
        
        self.properties.load(properties)
        
        self.colors?.primaryColor = self.properties.primaryColor
        self.colors?.primaryTextColor = self.properties.primaryTextColor
        self.colors?.textColor = self.colors?.textColor
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
