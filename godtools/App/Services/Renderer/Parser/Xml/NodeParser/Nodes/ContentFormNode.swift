//
//  ContentFormNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentFormNode: MobileContentXmlNode, ContentFormModelType {
        
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentFormNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
