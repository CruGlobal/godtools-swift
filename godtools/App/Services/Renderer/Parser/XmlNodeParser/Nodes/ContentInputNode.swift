//
//  ContentInputNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentInputNode: MobileContentXmlNode, ContentInputModelType {
        
    private var labelNode: ContentLabelNode?
    private var placeholderNode: ContentPlaceholderNode?
    
    let name: String?
    let required: String?
    let type: String?
    let value: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        name = attributes["name"]?.text
        required = attributes["required"]?.text
        type = attributes["type"]?.text
        value = attributes["value"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        if let labelNode = childNode as? ContentLabelNode {
            self.labelNode = labelNode
        }
        else if let placeholderNode = childNode as? ContentPlaceholderNode {
            self.placeholderNode = placeholderNode
        }
        
        super.addChild(childNode: childNode)
    }
    
    var inputType: MobileContentInputNodeType {
        
        guard let type = self.type else {
            return .unknown
        }
        
        return MobileContentInputNodeType(rawValue: type) ?? .unknown
    }
    
    var isRequired: Bool {
        return required == "true"
    }
    
    var text: String? {
        return labelNode?.textNode?.text
    }
    
    var placeholderText: String? {
        return placeholderNode?.textNode?.text
    }
}

// MARK: - MobileContentRenderableNode

extension ContentInputNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
