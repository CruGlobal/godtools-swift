//
//  KnowGodDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class KnowGodDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        if pathComponents.first == "lessons" {
            
            return parseLesson(url: url, pathComponents: pathComponents, queryParameters: queryParameters)
        }
        else {
         
            return parseTract(url: url, pathComponents: pathComponents, queryParameters: queryParameters)
        }
    }
    
    private func parseLesson(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
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
    
    private func parseTract(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
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
        
        var primaryLanguageCodesFromUrlQuery: [String] = knowGodQueryParameters?.getPrimaryLanguageCodes() ?? Array()
        
        if let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath, !primaryLanguageCodesFromUrlQuery.contains(primaryLanguageCodeFromUrlPath) {
            primaryLanguageCodesFromUrlQuery.insert(primaryLanguageCodeFromUrlPath, at: 0)
        }
        
        let parallelLanguageCodesFromUrlQuery: [String] = knowGodQueryParameters?.getParallelLanguageCodes() ?? Array()
             
        guard let resourceAbbreviation = abbreviationFromUrlPath, !resourceAbbreviation.isEmpty else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodesFromUrlQuery,
            parallelLanguageCodes: parallelLanguageCodesFromUrlQuery,
            liveShareStream: knowGodQueryParameters?.liveShareStream,
            page: pageFromUrlPath,
            pageId: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
 
