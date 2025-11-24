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
        
        if pathComponents[safe: 1] == "lesson" {
            return parseLesson(url: url, pathComponents: pathComponents, queryParameters: queryParameters)
        }
        else if pathComponents[safe: 1] == "tool" {
            return parseTool(url: url, pathComponents: pathComponents, queryParameters: queryParameters)
        }
        
        return nil
    }
    
    private func parseLesson(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
        
        guard let resourceAbbreviation = pathComponents[safe: 2] else {
            return nil
        }
        
        let primaryLanguageCodes: [String]
        
        if let language = pathComponents[safe: 0] {
            primaryLanguageCodes = [language]
        }
        else {
            primaryLanguageCodes = Array()
        }
        
        let pageNumber: Int?
        
        if let pageStringFromUrlPath = pathComponents[safe: 3] {
            pageNumber = Int(pageStringFromUrlPath)
        }
        else {
            pageNumber = nil
        }
                
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: pageNumber,
            pageId: nil,
            pageSubIndex: nil,
            selectedLanguageIndex: nil
        )
                       
        return .tool(toolDeepLink: toolDeepLink)
    }
    
    private func parseTool(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
        
        let knowGodQueryParameters: KnowGodTractDeepLinkQueryParameters? = JsonServices().decodeJsonObject(jsonObject: queryParameters)
        
        let primaryLanguageCodeFromUrlPath: String? = pathComponents[safe: 0]
        let abbreviationFromUrlPath: String? = pathComponents[safe: 3]
        let pageNumber: Int?
        let pageId: String?
        let pageSubIndex: Int?
        
        if let pageStringFromUrlPath = pathComponents[safe: 4] {
            if let pageIntegerFromUrlPath = Int(pageStringFromUrlPath) {
                pageNumber = pageIntegerFromUrlPath
                pageId = nil
            }
            else {
                pageNumber = nil
                pageId = pageStringFromUrlPath
            }
        }
        else {
            pageNumber = nil
            pageId = nil
        }
        
        if let pageSubIndexStringFromUrlPath = pathComponents[safe: 5] {
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
            page: pageNumber,
            pageId: pageId,
            pageSubIndex: pageSubIndex,
            selectedLanguageIndex: selectedLanguageIndex
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
