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
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        provider = attributes["provider"]?.text
        videoId = attributes["video-id"]?.text

        super.init(xmlElement: xmlElement)
    }
    
    var providerType: MobileContentVideoNodeProvider {
        return MobileContentVideoNodeProvider(rawValue: provider ?? "") ?? .unknown
    }
}
