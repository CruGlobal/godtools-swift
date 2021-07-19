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
        
    private let typeString: String?
    
    private var labelNode: ContentLabelNode?
    private var placeholderNode: ContentPlaceholderNode?
    
    let name: String?
    let required: String?
    let value: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        name = attributes["name"]?.text
        required = attributes["required"]?.text
        typeString = attributes["type"]?.text
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
    
    var type: MobileContentInputType {
        
        let defaultType: MobileContentInputType = .unknown
        
        guard let typeString = self.typeString?.lowercased() else {
            return defaultType
        }
        
        return MobileContentInputType(rawValue: typeString) ?? defaultType
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
