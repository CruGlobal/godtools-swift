//
//  ContentVideoNode.swift
//  godtools
//
//  Created by Robert Eldredge on 5/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentVideoNode: MobileContentXmlNode, ContentVideoModelType {
    
    let provider: String?
    let videoId: String?
    
    required init(xmlElement: XMLElement, position: Int) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        provider = attributes["provider"]?.text
        videoId = attributes["video-id"]?.text

        super.init(xmlElement: xmlElement, position: position)
    }
    
    var providerType: MobileContentVideoNodeProvider {
        return MobileContentVideoNodeProvider(rawValue: provider ?? "") ?? .unknown
    }
}

// MARK: - MobileContentRenderableNode

extension ContentVideoNode: MobileContentRenderableNode {
    
    var nodeContentIsRenderable: Bool {
        
        guard let videoId = self.videoId else {
            return false
        }
        
        guard !videoId.isEmpty else {
            return false
        }
        
        return true
    }
}
