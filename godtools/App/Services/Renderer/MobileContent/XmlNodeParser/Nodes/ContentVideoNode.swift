//
//  ContentVideoNode.swift
//  godtools
//
//  Created by Robert Eldredge on 5/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentVideoNode: MobileContentXmlNode {
    
    let provider: String?
    let videoId: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        provider = attributes["provider"]?.text
        videoId = attributes["videoId"]?.text

        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension ContentVideoNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
