//
//  TractProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractProperties: XMLNode {
    
    var primaryColor = GTAppDefaultStyle.primaryColor.getRGBAColor()
    var primaryTextColor = GTAppDefaultStyle.primaryTextColorString.getRGBAColor()
    var textColor = GTAppDefaultStyle.textColorString.getRGBAColor()
    var textScale: Int = 1
    var textSize: Int = 18
    
    required override init() {
        super.init()
    }
    
    override func getProperties() -> [String] {
        defineProperties()
        return ["primaryColor", "primaryTextColor", "textColor", "textScale", "textSize"] + self.properties
    }
    
    func setupDefaultProperties() { }
    
    func setupParentProperties(properties: TractProperties) {
        let set1 = Set(self.getProperties().map { $0 })
        let set2 = Set(properties.getProperties().map { $0 })
        let commonProperties = set1.intersection(set2)
        
        for property in commonProperties {
            let value = properties.value(forKey: property)
            self.setValue(value, forKey: property)
        }
    }
    
    func getTextProperties() -> TractTextContentProperties {
        let properties = TractTextContentProperties()
        properties.primaryColor = self.primaryColor
        properties.primaryTextColor = self.primaryTextColor
        properties.textColor = self.textColor
        return properties
    }

}
