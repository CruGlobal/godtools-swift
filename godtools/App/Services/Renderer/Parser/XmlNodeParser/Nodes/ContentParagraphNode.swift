
//
//  ContentParagraphNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import Foundation
import SWXMLHash

class ContentParagraphNode: MobileContentXmlNode, ContentParagraphModelType {
        
    required init(xmlElement: XMLElement, position: Int) {
        
        super.init(xmlElement: xmlElement, position: position)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentParagraphNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
