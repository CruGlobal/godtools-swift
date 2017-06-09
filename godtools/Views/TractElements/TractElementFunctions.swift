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
        let xmlManager = XMLManager()
        let contentElements = xmlManager.getContentElements(data)
        
        switch contentElements.kind {
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
        case "emails":
            return TractEmails(data: data, parent: self)
        case "email":
            return TractEmail(data: data, parent: self)
        default:
            return TractTextContent(data: data, startOnY: yPosition, parent: self)
        }
    }
    
    func elementListeners() -> [String]? {
        return nil
    }
    
    func elementDismissListeners() -> [String]? {
        return nil
    }
    
    func sendMessageToElement(listener: String) {
        if TractBindings.bindings[listener] != nil {
            guard let view = TractBindings.bindings[listener] else { return }
            view.receiveMessage()
        }
        
        if TractBindings.dismissBindings[listener] != nil {
            guard let view = TractBindings.dismissBindings[listener] else { return }
            view.receiveDismissMessage()
        }
        
        if TractBindings.pageBindings[listener] != nil {
            NotificationCenter.default.post(name: .moveToPageNotification, object: nil, userInfo: ["pageListener": listener])
        }
    }
    
    func receiveMessage() { }
    
    func receiveDismissMessage() { }
    
}
