//
//  ContentNode.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentNode: MobileContentXmlNode, ContentModelType {
    
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}


