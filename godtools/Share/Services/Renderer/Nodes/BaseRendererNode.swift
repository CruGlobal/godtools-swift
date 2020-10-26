//
//  BaseRendererNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class BaseRendererNode {
    
    private(set) weak var parentNode: BaseRendererNode?
    private(set) var childNodes: [BaseRendererNode] = Array()
    
    let name: String
    
    required init(xmlElement: XMLElement) {
        
        self.name = xmlElement.name
    }
    
    func addChild(node: BaseRendererNode) {
        
        childNodes.append(node)
        
        node.parentNode = self
    }
}
