//
//  XMLParseManager.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class XMLParseManager: NSObject {
    
    static let nodeHero: String = "hero"
    static let nodeHeading: String = "heading"
    static let nodeParagraph: String = "paragraph"
    static let nodeText: String = "text"
    static let nodeImage: String = "image"
    static let nodeHeader: String = "header"
    static let nodeNumber: String = "number"
    static let nodeTitle: String = "title"
    static let nodeCards: String = "cards"
    static let nodeCard: String = "card"
    static let nodeLabel: String = "label"
    static let nodeForm: String = "form"
    static let nodeButton: String = "button"
    static let nodeLink: String = "link"
    static let nodeInput: String = "input"
    static let nodePlaceholder: String = "placeholder"
    static let nodeCallToAction: String = "call-to-action"
    static let nodeTabs: String = "tabs"
    static let nodeModals: String = "modals"
    static let nodeModal: String = "modal"
    static let nodeEmails: String = "emails"
    static let nodeEmail: String = "email"
    static let nodeEvent: String = "event"
    static let nodeEvents: String = "events"
    static let nodeAttribute: String = "attribute"
    static let nodeAnalyticsAttribute: String = "analytics:attribute"
    
    func getNodeClass(_ data: XMLIndexer) -> BaseTractElement.Type {
        let xmlManager = XMLManager()
        let contentElements = xmlManager.getContentElements(data)
        
        switch contentElements.kind {
        case XMLParseManager.nodeHero:
            return TractHero.self
        case XMLParseManager.nodeHeading:
            return TractHeading.self
        case XMLParseManager.nodeParagraph:
            return TractParagraph.self
        case XMLParseManager.nodeText:
            return TractTextContent.self
        case XMLParseManager.nodeImage:
            return TractImage.self
        case XMLParseManager.nodeHeader:
            return TractHeader.self
        case XMLParseManager.nodeNumber:
            return TractNumber.self
        case XMLParseManager.nodeTitle:
            return TractTitle.self
        case XMLParseManager.nodeCards:
            return TractCards.self
        case XMLParseManager.nodeCard:
            return TractCard.self
        case XMLParseManager.nodeLabel:
            return TractLabel.self
        case XMLParseManager.nodeForm:
            return TractForm.self
        case XMLParseManager.nodeButton:
            return TractButton.self
        case XMLParseManager.nodeLink:
            return TractLink.self
        case XMLParseManager.nodeInput:
            return TractInput.self
        case XMLParseManager.nodeCallToAction:
            return TractCallToAction.self
        case XMLParseManager.nodeTabs:
            return TractTabs.self
        case XMLParseManager.nodeModals:
            return TractModals.self
        case XMLParseManager.nodeModal:
            return TractModal.self
        case XMLParseManager.nodeEmails:
            return TractEmails.self
        case XMLParseManager.nodeEmail:
            return TractEmail.self
        case XMLParseManager.nodeEvent:
            return TractEvent.self
        case XMLParseManager.nodeEvents:
            return TractEvent.self
        case XMLParseManager.nodeAttribute:
            return TractEvent.self
        case XMLParseManager.nodeAnalyticsAttribute:
            return TractEvent.self
        default:
            
            return TractTextContent.self
        }
    }
    
    func nodeIsHero(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeHero)
    }
    
    func nodeIsHeading(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeHeading)
    }
    
    func nodeIsParagraph(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeParagraph)
    }
    
    func nodeIsText(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeText)
    }
    
    func nodeIsImage(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeImage)
    }
    
    func nodeIsHeader(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeHeader)
    }
    
    func nodeIsNumber(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeNumber)
    }
    
    func nodeIsTitle(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeTitle)
    }
    
    func nodeIsCards(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeCards)
    }
    
    func nodeIsCard(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeCard)
    }
    
    func nodeIsLabel(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeLabel)
    }
    
    func nodeIsForm(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeForm)
    }
    
    func nodeIsButton(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeButton)
    }
    
    func nodeIsLink(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeLink)
    }
    
    func nodeIsInput(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeInput)
    }
    
    func nodeIsPlaceholder(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodePlaceholder)
    }
    
    func nodeIsCallToAction(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeCallToAction)
    }
    
    func nodeIsTabs(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeTabs)
    }
    
    func nodeIsModals(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeModals)
    }
    
    func nodeIsModal(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeModal)
    }
    
    func nodeIsEmails(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeEmails)
    }
    
    func nodeIsEmail(node: XMLIndexer) -> Bool {
        return nodeIsOfKind(node: node, kind: XMLParseManager.nodeEmail)
    }
    
    func nodeIsEvent(node: XMLIndexer) -> Bool {
        guard let name = node.element?.name else { return false }
        switch name {
        case "analytics:attribute":
            return true
        default:
            return nodeIsOfKind(node: node, kind: XMLParseManager.nodeEvent)
        }
    }
    
    func getTextContentFromElement(_ node: XMLIndexer) -> XMLElement? {
        if let textNode = node["content:text"].element {
            return textNode
        } else {
            return nil
        }
    }
    
    // MARK: - Helpers
    
    private func nodeIsOfKind(node: XMLIndexer, kind: String) -> Bool {
        let xmlManager = XMLManager()
        let contentElements = xmlManager.getContentElements(node)
        return contentElements.kind == kind
    }

}
