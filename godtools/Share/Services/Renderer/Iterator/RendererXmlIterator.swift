//
//  RendererXmlIterator.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class RendererXmlIterator: RendererIteratorType {
    
    private let factory: RendererNodeFactory = RendererNodeFactory()
    
    private(set) weak var delegate: RendererIteratorDelegate?
        
    required init() {
            
    }
    
    func iterate(xmlData: Data, delegate: RendererIteratorDelegate) -> BaseRendererNode? {
        
        self.delegate = delegate
        
        let xmlHash: XMLIndexer = SWXMLHash.parse(xmlData)
        let rootNode: BaseRendererNode? = createRootNode(xmlHash: xmlHash)
        
        return rootNode
    }
    
    private func createRootNode(xmlHash: XMLIndexer) -> BaseRendererNode? {
        
        if let rootXmlElement = xmlHash.element?.children.first as? XMLElement, let rootNode = factory.getRendererNode(id: rootXmlElement.name) {
            
            recurseXmlElementAndNode(
                xmlElement: rootXmlElement,
                node: rootNode,
                nodeParent: nil
            )
            
            return rootNode
        }
        else {
            return nil
        }
    }
    
    private func recurseXmlElementAndNode(xmlElement: XMLElement, node: BaseRendererNode, nodeParent: BaseRendererNode?) {
              
        delegate?.rendererIteratorDidIterateNode(rendererIterator: self, node: node)
        
        let childElements: [XMLContent] = xmlElement.children
        
        for childElement in childElements {
            
            if let childXmlElement = childElement as? XMLElement, let childNode = factory.getRendererNode(id: childXmlElement.name)  {
                             
                node.addChild(node: childNode)
                
                recurseXmlElementAndNode(xmlElement: childXmlElement, node: childNode, nodeParent: node)
            }
        }
    }
}
