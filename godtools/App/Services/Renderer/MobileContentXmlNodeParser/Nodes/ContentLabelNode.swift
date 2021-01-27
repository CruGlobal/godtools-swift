//
//  ContentLabelNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentLabelNode: MobileContentXmlNode {
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
}

// MARK: - MobileContentRenderableNode

extension ContentLabelNode: MobileContentRenderableNode {
    var contentIsRenderable: Bool {
        return true
    }
}
