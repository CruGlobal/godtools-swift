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
    
    private let modeString: String?
    
    let height: String?
    
    required init(xmlElement: XMLElement) {
        
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        height = attributes["height"]?.text
        modeString = attributes["mode"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    var mode: MobileContentSpacerMode {
        
        let defaultMode: MobileContentSpacerMode = .auto
        
        guard let modeString = self.modeString?.lowercased() else {
            return defaultMode
        }
        
        return MobileContentSpacerMode(rawValue: modeString) ?? defaultMode
    }
}
