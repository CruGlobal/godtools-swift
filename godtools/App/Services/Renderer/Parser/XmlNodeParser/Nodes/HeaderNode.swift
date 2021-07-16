//
//  HeaderNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class HeaderNode: MobileContentXmlNode, HeaderModelType {
    
    private var numberNode: NumberNode?
    private var titleNode: TitleNode?
    
    let trainingTip: String?
    
    required init(xmlElement: XMLElement, position: Int) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        trainingTip = attributes["training:tip"]?.text
        
        super.init(xmlElement: xmlElement, position: position)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        super.addChild(childNode: childNode)
        
        if let numberNode = childNode as? NumberNode {
            self.numberNode = numberNode
        }
        
        if let titleNode = children.last as? TitleNode {
            self.titleNode = titleNode
        }
    }
}

// MARK: - MobileContentRenderableNode

extension HeaderNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
