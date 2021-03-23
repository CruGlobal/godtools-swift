//
//  ModalNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ModalNode: MobileContentXmlNode {
        
    let dismissListeners: [String]
    let listeners: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ModalNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
