//
//  PageXmlNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

protocol PageXmlNode: class {
    
    var type: PageXmlNodeType { get }
    var rendererView: RendererNodeView? { get }
    var rendererModel: RendererNodeModel? { get }
    var renderer: NodeRendererType? { get }
    var parent: PageXmlNode? { get set }
    var children: [PageXmlNode] { get set }
    
    init(xmlElement: XMLElement, type: PageXmlNodeType)
    
    func addChildNodeViews(childNodes: [PageXmlNode])
}

extension PageXmlNode {
    
    func addChild(childNode: PageXmlNode) {
        
        children.append(childNode)
        
        childNode.parent = self
    }
}
