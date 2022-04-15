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
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        guard let resourceAbbreviation = pathComponents[safe: 1] else {
            return nil
        }
        
        let primaryLanguageCodes: [String]
        
        if let language = pathComponents[safe: 2] {
            primaryLanguageCodes = [language]
        }
        else {
            primaryLanguageCodes = Array()
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
