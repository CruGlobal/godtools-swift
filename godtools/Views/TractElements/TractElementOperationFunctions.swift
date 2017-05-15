//
//  TractElementOperationFunctions.swift
//  godtools
//
//  Created by Devserker on 5/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension BaseTractElement {
    
    func buildElementForDictionary(_ data: XMLIndexer, startOnY yPosition: CGFloat) -> BaseTractElement {
        let dataContent = splitData(data: data)
        
        switch dataContent.kind {
        case "hero":
            return Hero(data: data, startOnY: yPosition, parent: self)
        case "heading":
            return Heading(data: data, startOnY: yPosition, parent: self)
        case "paragraph":
            return Paragraph(data: data, startOnY: yPosition, parent: self)
        case "content:text":
            return TextContent(data: data, startOnY: yPosition, parent: self)
        case "header":
            return Header(data: data, startOnY: yPosition, parent: self)
        case "number":
            return Number(data: data, startOnY: yPosition, parent: self)
        case "title":
            return Title(data: data, startOnY: yPosition, parent: self)
        case "cards":
            return Cards(data: data, startOnY: yPosition, parent: self)
        case "card":
            return Card(data: data, startOnY: yPosition, parent: self)
        case "label":
            return TractLabel(data: data, startOnY: yPosition, parent: self)
        case "call-to-action":
            return CallToAction(data: data, startOnY: yPosition, parent: self)
        default:
            return TextContent(data: data, startOnY: yPosition, parent: self)
        }
    }
    
    func splitData(data: XMLIndexer) -> (kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
        let kind = data.element?.name
        var properties = [String: Any]()
        for item in (data.element?.allAttributes)! {
            let attribute = item.value as XMLAttribute
            properties[attribute.name] = attribute.text
        }
        properties["value"] = data.element?.text
        let children = data.children
        return (kind!, properties, children)
    }
    
}
