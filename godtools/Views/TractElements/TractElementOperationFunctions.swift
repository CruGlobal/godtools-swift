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
        var element:BaseTractElement?
        
        if dataContent.kind == "hero" {
            element = Hero(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "heading" {
            element = Heading(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "paragraph" {
            element = Paragraph(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "content:text" {
            element = TextContent(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "header" {
            element = Header(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "number" {
            element = Number(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "title" {
            element = Title(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "card" {
            element = Card(data: data, startOnY: yPosition, parent: self)
        } else if dataContent.kind == "label" {
            element = TractLabel(data: data, startOnY: yPosition, parent: self)
        } else {
            element = TextContent(data: data, startOnY: yPosition, parent: self)
        }
        
        return element!
    }
    
    func splitData(data: XMLIndexer) -> (kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
        let kind = data.element?.name
        var properties = Dictionary<String, Any>()
        for item in (data.element?.allAttributes)! {
            let attribute = item.value as XMLAttribute
            properties[attribute.name] = attribute.text
        }
        properties["value"] = data.element?.text
        let children = data.children
        return (kind!, properties, children)
    }
    
    func getCardsFromXML(_ data: [XMLIndexer]) -> [XMLIndexer] {
        var cards = [XMLIndexer]()
        
        for dictionary in data {
            let dataContent = splitData(data: dictionary)
            if dataContent.kind == "card" {
                cards.append(dictionary)
            }
        }
        
        return cards
    }
    
}
