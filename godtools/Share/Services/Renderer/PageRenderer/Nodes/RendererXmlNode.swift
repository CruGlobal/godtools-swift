//
//  RendererXmlNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

protocol RendererXmlNode: class {
    
    var type: PageXmlNodeType { get }
    var parent: RendererXmlNode? { get set }
    var children: [RendererXmlNode] { get set }
    
    init(xmlElement: XMLElement, type: PageXmlNodeType)
}

extension RendererXmlNode {
    
    func addChild(childNode: RendererXmlNode) {
        
        children.append(childNode)
        
        childNode.parent = self
    }
}
