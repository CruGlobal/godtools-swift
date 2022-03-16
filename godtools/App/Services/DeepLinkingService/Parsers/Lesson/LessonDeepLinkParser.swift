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
        
        let lessonPathComponents: LessonDeepLinkPathComponents = LessonDeepLinkPathComponents(pathComponents: pathComponents)
        
        let lessonQuery: LessonQueryParameters? = JsonServices().decodeJsonObject(jsonObject: incomingUrl.queryParameters)
        
        let lessonAbbreviation: String?
        
        if let queryAbbreviation = lessonQuery?.abbreviation {
            lessonAbbreviation = queryAbbreviation
        }
        else if let pathAbbreviation = lessonPathComponents.abbreviation {
            lessonAbbreviation = pathAbbreviation
        }
        else {
            lessonAbbreviation = nil
        }
        
        var primaryLanguageCodes: [String] = Array()
        
        if let pathPrimaryLanguage = lessonPathComponents.primaryLanguageCode {
            primaryLanguageCodes.append(pathPrimaryLanguage)
        }
        
        let queryPrimaryLanguageCodes: [String] = lessonQuery?.getPrimaryLanguageCodes() ?? []
        
        primaryLanguageCodes.append(contentsOf: queryPrimaryLanguageCodes)
        
        guard let resourceAbbreviation = lessonAbbreviation else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil,
            pageId: nil
        )
                       
        return .tool(toolDeepLink: toolDeepLink)
    }
}
