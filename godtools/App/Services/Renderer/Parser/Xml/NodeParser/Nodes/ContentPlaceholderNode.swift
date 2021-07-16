//
//  ContentPlaceholderNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentPlaceholderNode: MobileContentXmlNode {
        
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
    
    var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
}

// MARK: - MobileContentRenderableNode

extension ContentPlaceholderNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
