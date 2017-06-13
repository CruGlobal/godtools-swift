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
        case XMLParseManager.nodeHero:
            return TractHero(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeHeading:
            return TractHeading(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeParagraph:
            return TractParagraph(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeText:
            return TractTextContent(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeImage:
            return TractImage(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeHeader:
            return TractHeader(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeNumber:
            return TractNumber(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeTitle:
            return TractTitle(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeCards:
            return TractCards(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeCard:
            return TractCard(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeLabel:
            return TractLabel(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeForm:
            return TractForm(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeButton:
            return TractButton(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeLink:
            return TractLink(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeInput:
            return TractInput(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeCallToAction:
            return TractCallToAction(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeTabs:
            return TractTabs(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeModals:
            return TractModals(data: data, parent: self)
        case XMLParseManager.nodeModal:
            return TractModal(data: data, startOnY: yPosition, parent: self)
        case XMLParseManager.nodeEmails:
            return TractEmails(data: data, parent: self)
        case XMLParseManager.nodeEmail:
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
