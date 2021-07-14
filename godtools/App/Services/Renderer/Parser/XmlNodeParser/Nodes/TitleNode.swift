//
//  TitleNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TitleNode: MobileContentXmlNode {
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
}

// MARK: - MobileContentRenderableNode

extension TitleNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
