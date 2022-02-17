//
//  CYOADeepLinkParser.swift
//  godtools
//
//  Created by Robert Eldredge on 2/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class CYOADeepLinkParser: DeepLinkParserType {
    
    let supportedUrlHosts: [DeepLinkHostType] = [.godToolsApp, .knowGod]
    let supportedUrlSchemes: [DeepLinkSchemeType] = [.godtools]
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
                
        switch incomingDeepLink {
        
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
        
        default:
            return nil
        }
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        if let is_first_launch = data["is_first_launch"] as? Bool,
            is_first_launch {
            //Use if we want to trigger different behavior for deep link with fresh install
        }
        
        guard let deepLinkValue = data["deep_link_value"] as? String else {
            return nil
        }
        
        let linkParts = deepLinkValue.components(separatedBy: "|")
        
        guard linkParts[0] == "tool", linkParts[1] == "cyoa" else {
            return nil
        }
        
        let resourceAbbreviation = linkParts[2]
        
        let primaryLanguageCode = linkParts[3]
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: [primaryLanguageCode],
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
