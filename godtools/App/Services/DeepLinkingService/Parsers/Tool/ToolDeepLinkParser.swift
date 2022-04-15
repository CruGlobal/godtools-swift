//
//  ToolDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolDeepLinkParser: DeepLinkParserType {
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
                
        switch incomingDeepLink {
        
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
        
        case .url(let incomingUrl):
            return nil
        }
    }
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        if let toolTypeString = pathComponents[safe: 1],
           let toolPath = ToolDeepLinkToolPath(rawValue: toolTypeString),
           let resourceAbbreviation = pathComponents[safe: 2],
           let language = pathComponents[safe: 3] {
            
            let pageNumber: Int?
            let pageId: String?
            
            switch toolPath {
            
            case .tract:
                if let pageStringValue = pathComponents[safe: 4], let pageIntValue = Int(pageStringValue) {
                    pageNumber = pageIntValue
                }
                else {
                    pageNumber = nil
                }
                
                pageId = nil
            
            case .lesson:
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
    
    // TODO: Need to implement. ~Levi
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        let resourceAbbreviation: String?
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            resourceAbbreviation = deepLinkValue
        }
        else if let link = data["link"] as? String,
                let linkComponents = URLComponents(string: link),
                let deepLinkValue = linkComponents.queryItems?.first(where: { $0.name == "deep_link_value" })?.value {
            
            resourceAbbreviation = deepLinkValue
        }
        else {
            
            resourceAbbreviation = nil
        }

        guard let resourceAbbreviation = resourceAbbreviation else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: [],
            parallelLanguageCodes: [],
            liveShareStream: nil,
            page: nil,
            pageId: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
