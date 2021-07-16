//
//  ModalNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ModalNode: MobileContentXmlNode, ModalModelType {
    
    let dismissListeners: [String]
    let listeners: [String]
    
    required init(xmlElement: XMLElement, position: Int) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ModalNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}

// MARK: - MobileContentContainerNode

extension ModalNode: MobileContentContainerNode {
    
    var buttonColor: MobileContentRGBAColor? {
        return MobileContentRGBAColor(stringColor: "rgba(255,255,255,1)")
    }
    
    var buttonStyle: MobileContentButtonNodeStyle? {
        return .outlined
    }
    
    var primaryColor: MobileContentRGBAColor? {
        return MobileContentRGBAColor(stringColor: "rgba(0,0,0,0)")
    }
    
    var primaryTextColor: MobileContentRGBAColor? {
        return MobileContentRGBAColor(stringColor: "rgba(255,255,255,1)")
    }
    
    var textAlignment: MobileContentTextAlign? {
        return .center
    }
    
    var textColor: MobileContentRGBAColor? {
        return MobileContentRGBAColor(stringColor: "rgba(255,255,255,1)")
    }
}
