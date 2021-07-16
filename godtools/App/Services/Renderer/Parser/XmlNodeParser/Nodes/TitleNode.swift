//
//  TitleNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TitleNode: MobileContentXmlNode, TitleModelType {
    
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
    
    private var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
    
    func getTextColor() -> MobileContentRGBAColor? {
        return textNode?.getTextColor()
    }
}

// MARK: - MobileContentRenderableNode

extension TitleNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
