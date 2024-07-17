//
//  GodToolsAppLessonsPathDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GodToolsAppLessonsPathDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        guard pathComponents.first == "lessons" else {
            return nil
        }
        
        guard pathComponents.count > 1 else {
            return .lessonsList
        }
        
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
            pageId: nil,
            selectedLanguageIndex: nil
        )
                       
        return .tool(toolDeepLink: toolDeepLink)
    }
}
