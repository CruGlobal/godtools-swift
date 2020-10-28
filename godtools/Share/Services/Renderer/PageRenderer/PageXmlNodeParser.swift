//
//  PageXmlNodeParser.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

protocol PageXmlNodeParserDelegate: class {
    
    func pageXmlNodeParserDidParseNode(parser: PageXmlNodeParser, node: RendererXmlNode, nodeParent: RendererXmlNode?)
}

class PageXmlNodeParser {
    
    private let nodeFactory: PageXmlNodeFactory = PageXmlNodeFactory()
    
    private weak var delegate: PageXmlNodeParserDelegate?
    
    required init() {
        
    }
    
    func asyncParsePageXml(pageXml: Data, complete: @escaping ((_ pageNode: PageNode?) -> Void)) {
        
    }
    
    func asyncParsePageXmlElement(pageXmlElement: XMLElement, complete: @escaping ((_ pageNode: PageNode?) -> Void)) {
        
    }
    
    func parsePageXml(pageXml: Data, delegate: PageXmlNodeParserDelegate) -> PageNode? {
        
        // TODO: Implement. ~Levi
        return nil
    }
    
    func parsePageXmlElement(pageXmlElement: XMLElement, delegate: PageXmlNodeParserDelegate) -> PageNode? {
        
        return parse(xmlElement: pageXmlElement, delegate: delegate)
    }
    
    private func parse(xmlElement: XMLElement, delegate: PageXmlNodeParserDelegate) -> PageNode? {
        
        self.delegate = delegate
        
        guard let nodeType = PageXmlNodeType(rawValue: xmlElement.name) else {
            return nil
        }
        
        guard let pageNode = nodeFactory.getRendererNode(nodeType: nodeType, xmlElement: xmlElement) as? PageNode else {
            return nil
        }
        
        recurseXmlElementAndNode(
            xmlElement: xmlElement,
            node: pageNode,
            nodeParent: nil
        )
        
        return pageNode
    }
    
    private func recurseXmlElementAndNode(xmlElement: XMLElement, node: RendererXmlNode, nodeParent: RendererXmlNode?) {
        
        delegate?.pageXmlNodeParserDidParseNode(parser: self, node: node, nodeParent: nodeParent)
        
        let childElements: [XMLContent] = xmlElement.children
                
        for childElement in childElements {
            
            if let childXmlElement = childElement as? XMLElement {
                
                let childNodeType: PageXmlNodeType? = PageXmlNodeType(rawValue: childXmlElement.name)
                
                if let childNodeType = childNodeType, let childNode = nodeFactory.getRendererNode(nodeType: childNodeType, xmlElement: childXmlElement) {
                                    
                    node.addChild(childNode: childNode)
                    
                    recurseXmlElementAndNode(xmlElement: childXmlElement, node: childNode, nodeParent: node)
                }
            }
        }
    }
}
