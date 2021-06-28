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
        
        let pathComponents: [String] = getUrlPathComponents(url: url)
        
        guard let rootPath = pathComponents.first, rootPath == "lesson" else {
            return nil
        }
        
        let lessonQuery: LessonQueryParameters? = getDecodedUrlQuery(url: url)
        
        let lessonAbbreviation: String?
        
        if let abbreviation = lessonQuery?.abbreviation {
            lessonAbbreviation = abbreviation
        }
        else if pathComponents.count > 1 {
            lessonAbbreviation = pathComponents[1]
        }
        else {
            lessonAbbreviation = nil
        }
        
        guard let resourceAbbreviation = lessonAbbreviation else {
            return nil
        }
                       
        return .tool(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: lessonQuery?.getPrimaryLanguageCodes() ?? [],
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil
        )
    }
}
