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
    
    private let heightString: String?
    private let modeString: String?
        
    required init(xmlElement: XMLElement) {
        
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        heightString = attributes["height"]?.text
        modeString = attributes["mode"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    var height: Int32 {
        
        let defaultHeight: Int32 = 40
        
        if let heightString = heightString, let heightValue = Int32(heightString) {
            return heightValue
        }
        
        return defaultHeight
    }
    
    var mode: MobileContentSpacerMode {
        
        let defaultMode: MobileContentSpacerMode = .auto
        
        guard let modeString = self.modeString?.lowercased() else {
            return defaultMode
        }
        
        return MobileContentSpacerMode(rawValue: modeString) ?? defaultMode
    }
}
