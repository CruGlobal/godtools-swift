//
//  ToolDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        if let toolTypeString = pathComponents[safe: 1],
           let toolPath = ToolDeepLinkToolPath(rawValue: toolTypeString),
           let resourceAbbreviation = pathComponents[safe: 2],
           let language = pathComponents[safe: 3] {
            
            let pageNumber: Int?
            let pageId: String?
            
            switch toolPath {
            
            case .article:
                pageNumber = nil
                pageId = nil
                
            case .cyoa:
                pageNumber = nil
                if let pageIdValue = pathComponents[safe: 4] {
                    pageId = pageIdValue
                }
                else {
                    pageId = nil
                }
                
            case .lesson:
                pageNumber = nil
                pageId = nil
                
            case .tract:
                if let pageStringValue = pathComponents[safe: 4], let pageIntValue = Int(pageStringValue) {
                    pageNumber = pageIntValue
                }
                else {
                    pageNumber = nil
                }
                
                pageId = nil
            }
            
            return .tool(
                toolDeepLink: ToolDeepLink(
                    resourceAbbreviation: resourceAbbreviation,
                    primaryLanguageCodes: [language],
                    parallelLanguageCodes: [],
                    liveShareStream: nil,
                    page: pageNumber,
                    pageId: pageId
                )
            )
        }
        
        return nil
    }
}
