//
//  KnowGodDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class KnowGodDeepLinkParser: DeepLinkUrlParserInterface {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
        
        guard let toolType = pathComponents[safe: 0] else {
            return nil
        }
        
        switch toolType {
        case "lessons":
            return parseLesson(url: url, pathComponents: pathComponents, queryParameters: queryParameters)
        default:
            return parseTool(url: url, pathComponents: pathComponents, queryParameters: queryParameters)
        }
    }
    
    private func parseLesson(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
        
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
            pageSubIndex: nil,
            selectedLanguageIndex: nil
        )
                       
        return .tool(toolDeepLink: toolDeepLink)
    }
    
    private func parseTool(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
        
        let knowGodQueryParameters: KnowGodTractDeepLinkQueryParameters? = JsonServices().decodeJsonObject(jsonObject: queryParameters)
        
        let abbreviationFromUrlPath: String? = pathComponents[safe: 1]
        let primaryLanguageCodeFromUrlPath: String? = pathComponents[safe: 2]
        let pageFromUrlPath: Int?
        let pageSubIndex: Int?
        
        if let pageStringFromUrlPath = pathComponents[safe: 3] {
            pageFromUrlPath = Int(pageStringFromUrlPath)
        }
        else {
            pageFromUrlPath = nil
        }
        
        if let pageSubIndexStringFromUrlPath = pathComponents[safe: 4] {
            pageSubIndex = Int(pageSubIndexStringFromUrlPath)
        }
        else {
            pageSubIndex = nil
        }
        
        var primaryLanguageCodes: [String] = knowGodQueryParameters?.getPrimaryLanguageCodes() ?? Array()
        let parallelLanguageCodes: [String] = knowGodQueryParameters?.getParallelLanguageCodes() ?? Array()
        let selectedLanguageIndex: Int?
        
        if primaryLanguageCodes.isEmpty, let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath, !parallelLanguageCodes.contains(primaryLanguageCodeFromUrlPath) {
            primaryLanguageCodes.append(primaryLanguageCodeFromUrlPath)
        }
        
        if let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath {
            
            if primaryLanguageCodes.contains(primaryLanguageCodeFromUrlPath) {
                selectedLanguageIndex = 0
            }
            else if parallelLanguageCodes.contains(primaryLanguageCodeFromUrlPath) {
                selectedLanguageIndex = 1
            }
            else {
                selectedLanguageIndex = nil
            }
        }
        else {
            selectedLanguageIndex = nil
        }
             
        guard let resourceAbbreviation = abbreviationFromUrlPath, !resourceAbbreviation.isEmpty else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: parallelLanguageCodes,
            liveShareStream: knowGodQueryParameters?.liveShareStream,
            page: pageFromUrlPath,
            pageId: nil,
            pageSubIndex: pageSubIndex,
            selectedLanguageIndex: selectedLanguageIndex
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
