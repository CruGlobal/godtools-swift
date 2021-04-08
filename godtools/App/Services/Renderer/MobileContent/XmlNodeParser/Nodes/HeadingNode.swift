//
//  HeadingNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class HeadingNode: MobileContentXmlNode {
        
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
}

// MARK: - MobileContentRenderableNode

extension HeadingNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
