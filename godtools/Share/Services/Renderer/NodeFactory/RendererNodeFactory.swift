//
//  RendererNodeFactory.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RendererNodeFactory {
    
    let rendererNodeFactory: [RendererNodeType: BaseRendererNode.Type]
    
    required init() {
        
        let allNodeTypes: [RendererNodeType] = RendererNodeType.allCases
        
        var factory: [RendererNodeType: BaseRendererNode.Type] = Dictionary()
        
        for nodeType in allNodeTypes {
            
            factory[nodeType] = RendererNodeFactory.getRendererNodeClass(nodeType: nodeType)
        }
        
        self.rendererNodeFactory = factory
    }
    
    func getRendererNode(id: String) -> BaseRendererNode? {
        
        guard let nodeType = RendererNodeType(rawValue: id) else {
            return nil
        }
        
        guard let RendererNodeClass = rendererNodeFactory[nodeType] else {
            return nil
        }
        
        return RendererNodeClass.init(id: id, nodeType: nodeType)
    }
    
    static func getRendererNodeClass(nodeType: RendererNodeType) -> BaseRendererNode.Type {
        
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
