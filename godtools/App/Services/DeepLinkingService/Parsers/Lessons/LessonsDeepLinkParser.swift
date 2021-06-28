//
//  LessonsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonsDeepLinkParser: DeepLinkParserType {
        
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
        
        switch incomingDeepLink {
       
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
            
        case .url(let url):
            return parseDeepLinkFromUrl(url: url)
        }
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        return nil
    }
    
    private func parseDeepLinkFromUrl(url: URL) -> ParsedDeepLinkType? {
        
        guard url.containsDeepLinkHost(deepLinkHost: .knowGod) ||
                url.containsDeepLinkHost(deepLinkHost: .godToolsApp) ||
                url.hostContainsDeepLinkScheme(scheme: .godtools) else {
            return nil
        }
        
        let pathComponents: [String] = getUrlPathComponents(url: url)
        
        guard let rootPath = pathComponents.first, rootPath == "lessons" else {
            return nil
        }
        
        return .lessonsList
    }
}
