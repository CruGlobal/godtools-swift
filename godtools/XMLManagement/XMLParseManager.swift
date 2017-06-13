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
