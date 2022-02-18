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
        
        guard linkParts[safe: 0] == "tool", linkParts[safe: 1] == "cyoa", let resourceAbbreviation = linkParts[safe: 2] else {
            return nil
        }
        
        let primaryLanguageCode = linkParts[safe: 3]
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCode != nil ? [primaryLanguageCode!] : [],
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
