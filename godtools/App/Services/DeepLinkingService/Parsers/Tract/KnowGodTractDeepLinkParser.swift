//
//  KnowGodTractDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class KnowGodTractDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        let knowGodQueryParameters: KnowGodTractDeepLinkQueryParameters? = JsonServices().decodeJsonObject(jsonObject: queryParameters)
        
        var abbreviationFromUrlPath: String?
        var primaryLanguageCodeFromUrlPath: String?
        var pageFromUrlPath: Int?
        
        if pathComponents.count > 1 {
            abbreviationFromUrlPath = pathComponents[1]
        }
        
        if pathComponents.count > 0 {
            primaryLanguageCodeFromUrlPath = pathComponents[0]
        }
        
        if pathComponents.count > 2, let pageIntegerValue = Int(pathComponents[2]) {
            pageFromUrlPath = pageIntegerValue
        }
        
        var primaryLanguageCodes: [String] = knowGodQueryParameters?.getPrimaryLanguageCodes() ?? Array()
        
        if let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath {
            primaryLanguageCodes.insert(primaryLanguageCodeFromUrlPath, at: 0)
        }
             
        guard let resourceAbbreviation = abbreviationFromUrlPath, !resourceAbbreviation.isEmpty else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: knowGodQueryParameters?.getParallelLanguageCodes() ?? [],
            liveShareStream: knowGodQueryParameters?.liveShareStream,
            page: pageFromUrlPath,
            pageId: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
