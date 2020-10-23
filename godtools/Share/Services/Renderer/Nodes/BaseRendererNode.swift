//
//  BaseRendererNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class BaseRendererNode {
    
    private(set) weak var parentNode: BaseRendererNode?
    private(set) var childNodes: [BaseRendererNode] = Array()
    
    let id: String
    let nodeType: RendererNodeType
    
    required init(id: String, nodeType: RendererNodeType) {
        
        self.id = id
        self.nodeType = nodeType
    }
    
    func addChild(node: BaseRendererNode) {
        
        childNodes.append(node)
        
        node.parentNode = self
    }
}
