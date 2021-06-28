//
//  LessonDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonDeepLinkParser: DeepLinkParserType {
    
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
        
        guard url.containsDeepLinkHost(deepLinkHost: .godToolsApp) else {
            return nil
        }
        
        let pathComponents: [String] = url.pathComponents.filter({$0 != "/"})
        
        guard let rootPath = pathComponents.first, rootPath == "lesson" else {
            return nil
        }
        
        guard pathComponents.count > 1 else {
            return nil
        }
        
        let lessonAbbreviation: String = pathComponents[1]
        
        return .tool(resourceAbbreviation: lessonAbbreviation, primaryLanguageCodes: ["en"], parallelLanguageCodes: [], liveShareStream: nil, page: nil)
    }
}
