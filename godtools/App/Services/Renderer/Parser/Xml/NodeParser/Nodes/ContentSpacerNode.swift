//
//  ContentSpacerNode.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentSpacerNode: MobileContentXmlNode, ContentSpacerModelType {
    
    let mode: String?
    let height: String?
    
    required init(xmlElement: XMLElement) {
        
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        mode = attributes["mode"]?.text
        height = attributes["height"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    var spacerMode: MobileContentSpacerMode {
        
        let defaultMode: MobileContentSpacerMode = .auto
        
        guard let modeValue = self.mode, !modeValue.isEmpty else {
            return defaultMode
        }
        
        return MobileContentSpacerMode(rawValue: modeValue) ?? defaultMode
    }
}
