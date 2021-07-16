//
//  ContentFallbackNode.swift
//  godtools
//
//  Created by Levi Eggert on 1/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//
import Foundation
import SWXMLHash

class ContentFallbackNode: MobileContentXmlNode {
 
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentFallbackNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
