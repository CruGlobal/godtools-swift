//
//  PageXmlRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class PageXmlRenderer {
    
    private let nodeFactory: PageXmlNodeFactory = PageXmlNodeFactory()
    
    required init() {
        
    }
    
    func renderPage(pageXml: Data) -> PageXmlNode? {
        
        return nil
    }
    
    func renderPage(pageXmlElement: XMLElement) -> PageXmlNode? {
        
        return render(xmlElement: pageXmlElement)
    }
    
    private func render(xmlElement: XMLElement) -> PageXmlNode? {
        
        guard let nodeType = PageXmlNodeType(rawValue: xmlElement.name) else {
            return nil
        }
        
        guard let rootNode = nodeFactory.getRendererNode(nodeType: nodeType, xmlElement: xmlElement) else {
            return nil
        }
        
        recurseXmlElementAndNode(
            xmlElement: xmlElement,
            node: rootNode,
            nodeParent: nil
        )
        
        return rootNode
    }
    
    private func recurseXmlElementAndNode(xmlElement: XMLElement, node: PageXmlNode, nodeParent: PageXmlNode?) {
                
        print("\n Recurse")
        print("  node: \(node.type)")
        print("  node parent: \(nodeParent?.type)")
        
        let childElements: [XMLContent] = xmlElement.children
                
        for childElement in childElements {
            
            if let childXmlElement = childElement as? XMLElement {
                
                let childNodeType: PageXmlNodeType? = PageXmlNodeType(rawValue: childXmlElement.name)
                
                if let childNodeType = childNodeType, let childNode = nodeFactory.getRendererNode(nodeType: childNodeType, xmlElement: childXmlElement) {
                
                    print("    child: \(childNodeType)")
                    
                    node.addChild(childNode: childNode)
                    
                    recurseXmlElementAndNode(xmlElement: childXmlElement, node: childNode, nodeParent: node)
                }
            }
        }
        
        node.renderer?.render(children: node.children)
    }
}
