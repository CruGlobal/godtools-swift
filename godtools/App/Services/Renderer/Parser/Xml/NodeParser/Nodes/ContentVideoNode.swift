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
    
    private let providerString: String?
    
    let videoId: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        providerString = attributes["provider"]?.text
        videoId = attributes["video-id"]?.text

        super.init(xmlElement: xmlElement)
    }
    
    var provider: MobileContentVideoProvider {
        
        let defaultProvider: MobileContentVideoProvider = .unknown
        
        guard let providerString = self.providerString?.lowercased() else {
            return defaultProvider
        }
        
        return MobileContentVideoProvider(rawValue: providerString) ?? defaultProvider
    }
}
