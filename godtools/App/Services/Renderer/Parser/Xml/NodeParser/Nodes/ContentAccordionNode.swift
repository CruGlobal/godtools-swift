//
//  ContentAccordionNode.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentAccordionNode: MobileContentXmlNode, ContentAccordionModelType {
    
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentAccordionNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
