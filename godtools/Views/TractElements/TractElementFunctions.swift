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
    
    func receiveMessage() {
    }
    
    func buildElementForDictionary(_ data: XMLIndexer, startOnY yPosition: CGFloat) -> BaseTractElement {
        let dataContent = splitData(data: data)
        
        switch dataContent.kind {
        case "hero":
            return TractHero(data: data, startOnY: yPosition, parent: self)
        case "heading":
            return TractHeading(data: data, startOnY: yPosition, parent: self)
        case "paragraph":
            return TractParagraph(data: data, startOnY: yPosition, parent: self)
        case "text":
            return TractTextContent(data: data, startOnY: yPosition, parent: self)
        case "image":
            return TractImage(data: data, startOnY: yPosition, parent: self)
        case "header":
            return TractHeader(data: data, startOnY: yPosition, parent: self)
        case "number":
            return TractNumber(data: data, startOnY: yPosition, parent: self)
        case "title":
            return TractTitle(data: data, startOnY: yPosition, parent: self)
        case "cards":
            return TractCards(data: data, startOnY: yPosition, parent: self)
        case "card":
            return TractCard(data: data, startOnY: yPosition, parent: self)
        case "label":
            return TractLabel(data: data, startOnY: yPosition, parent: self)
        case "form":
            return TractForm(data: data, startOnY: yPosition, parent: self)
        case "button":
            return TractButton(data: data, startOnY: yPosition, parent: self)
        case "link":
            return TractLink(data: data, startOnY: yPosition, parent: self)
        case "input":
            return TractInput(data: data, startOnY: yPosition, parent: self)
        case "call-to-action":
            return TractCallToAction(data: data, startOnY: yPosition, parent: self)
        case "tabs":
            return TractTabs(data: data, startOnY: yPosition, parent: self)
        case "modals":
            return TractModals(data: data, parent: self)
        case "modal":
            return TractModal(data: data, startOnY: yPosition, parent: self)
        default:
            return TractTextContent(data: data, startOnY: yPosition, parent: self)
        }
    }
    
    func splitData(data: XMLIndexer) -> (elementName: String, namespace: String, kind: String, properties: Dictionary<String, Any>, children: [XMLIndexer]) {
        let elementName = data.element?.name
        let elementNameArray = elementName?.components(separatedBy: ":")
        var namespace = ""
        var kind = ""
        
        if (elementNameArray?.count)! > 1 {
            namespace = elementNameArray![0] as String
            kind = elementNameArray![1] as String
        } else {
            kind = elementNameArray![0] as String
        }
        
        var properties = [String: Any]()
        for item in (data.element?.allAttributes)! {
            let attribute = item.value as XMLAttribute
            properties[attribute.name] = attribute.text
        }
        
        if data.element?.text != nil && data.element?.text?.trimmingCharacters(in: .whitespaces) != "" {
            properties["value"] = data.element?.text
        }

        let children = data.children
        return (elementName!, namespace, kind, properties, children)
    }
    
}
