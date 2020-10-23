//
//  RendererNodeIterator.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RendererNodeIterator: RendererIteratorType {
    
    private(set) weak var delegate: RendererIteratorDelegate?
        
    required init() {
        
    }
    
    func iterate(node: BaseRendererNode, delegate: RendererIteratorDelegate) {
        
        self.delegate = delegate
        
        recurseNode(node: node)
    }
    
    private func recurseNode(node: BaseRendererNode) {
        
        delegate?.rendererIteratorDidIterateNode(rendererIterator: self, node: node)
        
        for childNode in node.childNodes {
            recurseNode(node: childNode)
        }
    }
}
