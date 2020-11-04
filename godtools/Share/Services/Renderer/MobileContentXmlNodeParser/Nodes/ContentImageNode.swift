//
//  ContentImageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentImageNode: MobileContentXmlNode {
        
    let resource: String?
    let restrictTo: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        resource = attributes["resource"]?.text
        restrictTo = attributes["restrictTo"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}

extension ContentImageNode {
    
    enum RestrictToType: String {
        
        case mobile = "mobile"
        case web = "web"
        case noRestriction = "noRestriction"
    }
    
    var restrictToType: RestrictToType {
        
        guard let restrictToValue = restrictTo else {
            return .noRestriction
        }
        
        guard let restrictToType = RestrictToType(rawValue: restrictToValue) else {
            return .noRestriction
        }
        
        return restrictToType
    }
}
