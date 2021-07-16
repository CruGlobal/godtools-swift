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
    
    required init(xmlElement: XMLElement, position: Int) {
        
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        mode = attributes["mode"]?.text
        height = attributes["height"]?.text
        
        super.init(xmlElement: xmlElement, position: position)
    }
    
    var spacerMode: MobileContentSpacerMode {
        
        let defaultMode: MobileContentSpacerMode = .auto
        
        guard let modeValue = self.mode, !modeValue.isEmpty else {
            return defaultMode
        }
        
        return MobileContentSpacerMode(rawValue: modeValue) ?? defaultMode
    }
}

// MARK: - MobileContentRenderableNode

extension ContentSpacerNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
