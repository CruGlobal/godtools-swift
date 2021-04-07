//
//  NumberNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class NumberNode: MobileContentXmlNode {
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
}

// MARK: - MobileContentRenderableNode

extension NumberNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
