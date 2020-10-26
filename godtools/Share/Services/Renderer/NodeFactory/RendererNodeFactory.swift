//
//  RendererNodeFactory.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class RendererNodeFactory {
    
    private let factory: [RendererNodeType: BaseRendererNode.Type]
    
    required init() {
        
        let allNodeTypes: [RendererNodeType] = RendererNodeType.allCases
        
        var factory: [RendererNodeType: BaseRendererNode.Type] = Dictionary()
        
        for nodeType in allNodeTypes {
            
            factory[nodeType] = RendererNodeFactory.getRendererNodeClass(nodeType: nodeType)
        }
        
        self.factory = factory
    }
    
    func getRendererNode(xmlElement: XMLElement) -> BaseRendererNode? {
        
        guard let nodeType = RendererNodeType(rawValue: xmlElement.name) else {
            return nil
        }
        
        guard let RendererNodeClass = factory[nodeType] else {
            return nil
        }
        
        return RendererNodeClass.init(xmlElement: xmlElement)
    }
    
    private static func getRendererNodeClass(nodeType: RendererNodeType) -> BaseRendererNode.Type {
        
        switch nodeType {
            
        case .contentParagraph:
            return RendererContentParagraphNode.self
        
        case .contentText:
            return RendererContentTextNode.self
        
        case .contentImage:
            return RendererContentImageNode.self
        
        case .trainingTip:
            return RendererTrainingTipNode.self
            
        case .heading:
            return RendererHeadingNode.self
            
        case .hero:
            return RendererHeroNode.self
            
        case .pages:
            return RendererPagesNode.self
            
        case .page:
            return RendererPageNode.self
            
        case .tip:
            return RendererTipNode.self
        }
    }
}
