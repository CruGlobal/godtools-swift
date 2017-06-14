//
//  TractProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractProperties: XMLNode {
    
    var parentProperties: TractProperties?
    
    required override init() {
        super.init()
    }
    
    func setupDefaultProperties(properties: TractProperties) {
        let set1 = Set(self.properties()!.map { $0 })
        let set2 = Set(properties.properties()!.map { $0 })
        let commonProperties = set1.intersection(set2)
        
        for property in commonProperties {
            let value = properties.value(forKey: property)
            self.setValue(value, forKey: property)
        }
    }
    
    func getTextProperties() -> TractTextContentProperties {
        return TractTextContentProperties()
    }

}
