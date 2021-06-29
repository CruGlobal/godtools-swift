//
//  ToolsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolsDeepLinkParser: DeepLinkParserType {
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
        
        switch incomingDeepLink {
        
        case .appsFlyer(let data):
            return nil
            
        case .url(let incomingUrl):
            return parseDeepLinkFromUrl(incomingUrl: incomingUrl)
        }
    }
    
    private func parseDeepLinkFromUrl(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
        
        let rootPath: String? = incomingUrl.rootPath
        
        if rootPath == DeepLinkPathType.favoritedTools.rawValue {
            return .favoritedToolsList
        }
        else if rootPath == DeepLinkPathType.allTools.rawValue {
            return .allToolsList
        }
        
        if incomingUrl.url.containsDeepLinkHost(deepLinkHost: .knowGod) && incomingUrl.rootPath == nil {
            return .allToolsList
        }
        
        return nil
    }
}
