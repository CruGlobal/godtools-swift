//
//  ToolPathDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPathDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        guard let toolPathIndex = pathComponents.firstIndex(of: "tool") else {
            return nil
        }
        
        guard let toolPathValue = pathComponents[safe: toolPathIndex + 1], let toolPath = ToolDeepLinkToolPath(rawValue: toolPathValue) else {
            return nil
        }
        
        guard let resourceAbbreviation = pathComponents[safe: toolPathIndex + 2],
              let language = pathComponents[safe: toolPathIndex + 3] else {
            
            return nil
        }
        
        let pagePathValue: String? = pathComponents[safe: toolPathIndex + 4]
        let pageNumber: Int?
        let pageId: String?
        
        switch toolPath {
        
        case .article:
            
            pageNumber = nil
            pageId = nil
            
        case .cyoa:
            
            pageNumber = nil
            
            if let pagePathValue = pagePathValue {
                pageId = pagePathValue
            }
            else {
                pageId = nil
            }
            
        case .lesson:
            
            pageNumber = nil
            pageId = nil
            
        case .tract:
            
            if let pagePathValue = pagePathValue, let pageIntValue = Int(pagePathValue) {
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
}
