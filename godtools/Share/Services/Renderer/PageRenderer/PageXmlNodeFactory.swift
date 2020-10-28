//
//  PageXmlNodeFactory.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class PageXmlNodeFactory {
    
    private let factory: [PageXmlNodeType: RendererXmlNode.Type]
    
    required init() {
        
        let allNodeTypes: [PageXmlNodeType] = PageXmlNodeType.allCases
        
        var factory: [PageXmlNodeType: RendererXmlNode.Type] = Dictionary()
        
        for nodeType in allNodeTypes {
            
            factory[nodeType] = PageXmlNodeFactory.getRendererNodeClass(nodeType: nodeType)
        }
        
        self.factory = factory
    }
    
    func getRendererNode(nodeType: PageXmlNodeType, xmlElement: XMLElement) -> RendererXmlNode? {
        
        guard let RendererNodeClass = factory[nodeType] else {
            return nil
        }
        
        return RendererNodeClass.init(xmlElement: xmlElement, type: nodeType)
    }
    
    private static func getRendererNodeClass(nodeType: PageXmlNodeType) -> RendererXmlNode.Type {
        
        switch nodeType {
            
        case .contentParagraph:
            return ContentParagraphNode.self
        
        case .contentText:
            return ContentTextNode.self
            
        case .contentImage:
            return ContentImageNode.self
            
        case .page:
            return PageNode.self
        }
    }
}
