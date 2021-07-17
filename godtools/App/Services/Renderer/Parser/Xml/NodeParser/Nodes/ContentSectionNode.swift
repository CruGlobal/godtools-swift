//
//  ContentSectionNode.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentSectionNode: MobileContentXmlNode, ContentSectionModelType {
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentSectionNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
