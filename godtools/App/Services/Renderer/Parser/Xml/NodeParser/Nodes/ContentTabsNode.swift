//
//  ContentTabsNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentTabsNode: MobileContentXmlNode, ContentTabsModelType {
    
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentTabsNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
