//
//  ContentHeaderNode.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentHeaderNode: MobileContentXmlNode {
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentHeaderNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
