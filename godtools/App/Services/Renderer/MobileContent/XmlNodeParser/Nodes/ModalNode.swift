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
    
    let buttonColor: String
    let buttonStyle: String
    let dismissListeners: [String]
    let listeners: [String]
    let primaryColor: String
    let primaryTextColor: String
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        buttonColor = "rgba(255,255,255,1)"
        buttonStyle = MobileContentButtonNodeStyle.outlined.rawValue
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        primaryColor = "rgba(0,0,0,0)"
        primaryTextColor = "rgba(255,255,255,1)"
        
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ModalNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
