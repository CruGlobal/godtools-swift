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
            
        case .url(let incomingUrl):
            return parseDeepLinkFromUrl(incomingUrl: incomingUrl)
        }
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        return nil
    }
    
    private func parseDeepLinkFromUrl(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
        
        let pathComponents: [String] = incomingUrl.pathComponents
        
        guard let rootPath = pathComponents.first, rootPath == DeepLinkPathType.lessons.rawValue else {
            return nil
        }
        
        let lessonQuery: LessonQueryParameters? = JsonServices().decodeJsonObject(jsonObject: incomingUrl.queryParameters)
        
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
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: lessonQuery?.getPrimaryLanguageCodes() ?? [],
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil
        )
                       
        return .tool(toolDeepLink: toolDeepLink)
    }
}
