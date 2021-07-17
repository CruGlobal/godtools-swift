//
//  MobileContentXmlNodeParser.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

protocol MobileContentXmlNodeParserDelegate: AnyObject {
    
    func mobileContentXmlNodeParserDidParseNode(parser: MobileContentXmlNodeParser, node: MobileContentXmlNode)
}

class MobileContentXmlNodeParser {
    
    private let nodeFactory: MobileContentXmlNodeFactory = MobileContentXmlNodeFactory()
        
    private weak var delegate: MobileContentXmlNodeParserDelegate?
    
    required init() {
        
    }
    
    func asyncParse(xml: Data, complete: @escaping ((_ node: MobileContentXmlNode?) -> Void)) {
        
        DispatchQueue.global().async { [weak self] in
            let node: MobileContentXmlNode? = self?.parse(xml: xml, delegate: nil)
            complete(node)
        }
    }
    
    func asyncParseXmlElement(xmlElement: XMLElement, complete: @escaping ((_ node: MobileContentXmlNode?) -> Void)) {
        
        DispatchQueue.global().async { [weak self] in
            let node: MobileContentXmlNode? = self?.parseXmlElement(xmlElement: xmlElement, delegate: nil)
            complete(node)
        }
    }
    
    func parse(xml: Data, delegate: MobileContentXmlNodeParserDelegate?) -> MobileContentXmlNode? {
        
        self.delegate = delegate
        
        let xmlHash: XMLIndexer = SWXMLHash.parse(xml)
        
        guard let rootXmlElement = xmlHash.element?.children.first as? XMLElement else {
            return nil
        }
        
        return parseXmlElement(xmlElement: rootXmlElement, delegate: delegate)
    }
    
    func parseXmlElement(xmlElement: XMLElement, delegate: MobileContentXmlNodeParserDelegate?) -> MobileContentXmlNode? {
        
        self.delegate = delegate
        
        guard let nodeType = MobileContentXmlNodeType(rawValue: xmlElement.name) else {
            return nil
        }
        
        guard let node = nodeFactory.getNode(nodeType: nodeType, xmlElement: xmlElement) else {
            return nil
        }
        
        recurseXmlElementAndNode(
            xmlElement: xmlElement,
            node: node,
            nodeParent: nil
        )
        
        return node
    }
    
    private func recurseXmlElementAndNode(xmlElement: XMLElement, node: MobileContentXmlNode, nodeParent: MobileContentXmlNode?) {
               
        delegate?.mobileContentXmlNodeParserDidParseNode(parser: self, node: node)
                
        let childElements: [XMLContent] = xmlElement.children
                        
        for childElement in childElements {
            
            if let childXmlElement = childElement as? XMLElement {
                
                let childNodeType: MobileContentXmlNodeType? = MobileContentXmlNodeType(rawValue: childXmlElement.name)
                
                if let childNodeType = childNodeType, let childNode = nodeFactory.getNode(nodeType: childNodeType, xmlElement: childXmlElement) {
                                    
                    recurseXmlElementAndNode(xmlElement: childXmlElement, node: childNode, nodeParent: node)
                    
                    node.addChild(childNode: childNode)
                }
            }
        }
    }
}
