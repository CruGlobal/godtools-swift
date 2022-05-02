//
//  LegacyAppsFlyerDeepLinkValueParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LegacyAppsFlyerDeepLinkValueParser: DeepLinkAppsFlyerParserType {
    
    required init() {
        
    }
    
    func parse(data: [AnyHashable : Any]) -> ParsedDeepLinkType? {
        
        let resourceAbbreviation: String?
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            resourceAbbreviation = deepLinkValue
        }
        else if let link = data["link"] as? String,
                let linkComponents = URLComponents(string: link),
                let deepLinkValue = linkComponents.queryItems?.first(where: { $0.name == "deep_link_value" })?.value {
            
            resourceAbbreviation = deepLinkValue
        }
        else {
            
            resourceAbbreviation = nil
        }

        guard let resourceAbbreviation = resourceAbbreviation else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: [],
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil,
            pageId: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
