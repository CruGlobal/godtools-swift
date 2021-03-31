//
//  ContentSpacerNode.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentSpacerNode: MobileContentXmlNode {
    
    required init(xmlElement: XMLElement) {
        
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentSpacerNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
