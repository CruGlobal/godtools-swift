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
    
    private let rendererNodeFactory: RendererNodeFactory = RendererNodeFactory()
    
    private(set) weak var delegate: RendererIteratorDelegate?
        
    required init() {
            
    }
    
    func asyncIterate(xmlData: Data, complete: @escaping ((_ rootNode: BaseRendererNode?) -> Void)) {
        
        DispatchQueue.global().async { [weak self] in
            
            let rootNode: BaseRendererNode? = self?.createRootNode(xmlData: xmlData)
            
            complete(rootNode)
        }
    }
    
    func iterate(xmlData: Data, delegate: RendererIteratorDelegate) -> BaseRendererNode? {
        
        self.delegate = delegate
            
        let rootNode: BaseRendererNode? = createRootNode(xmlData: xmlData)
        
        return rootNode
    }
    
    private func createRootNode(xmlData: Data) -> BaseRendererNode? {
        
        let xmlHash: XMLIndexer = SWXMLHash.parse(xmlData)
        
        if let rootXmlElement = xmlHash.element?.children.first as? XMLElement, let rootNode = rendererNodeFactory.getRendererNode(xmlElement: rootXmlElement) {
            
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
            
            if let childXmlElement = childElement as? XMLElement, let childNode = rendererNodeFactory.getRendererNode(xmlElement: childXmlElement)  {
            
                node.addChild(node: childNode)
                
                recurseXmlElementAndNode(xmlElement: childXmlElement, node: childNode, nodeParent: node)
            }
        }
    }
}
