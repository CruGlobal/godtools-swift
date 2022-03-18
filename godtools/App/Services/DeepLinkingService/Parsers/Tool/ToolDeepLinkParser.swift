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
            
            if incomingUrl.url.containsDeepLinkHost(deepLinkHost: .knowGod) {
                return parseDeepLinkFromKnowGod(incomingUrl: incomingUrl)
            }
            
            return parseDefaultUrlStructure(incomingUrl: incomingUrl)
        }
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        if let is_first_launch = data["is_first_launch"] as? Bool,
            is_first_launch {
            //Use if we want to trigger different behavior for deep link with fresh install
        }
        
        let resourceAbbreviation: String
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            
            resourceAbbreviation = deepLinkValue
        }
        else {
            
            guard let linkParam = data["link"] as? String,
                  let urlComponents = URLComponents(string: linkParam),
                  let deepLinkValue = urlComponents.queryItems?.first(where: { $0.name == "deep_link_value" })?.value else {
                
                return nil
            }
            
            resourceAbbreviation = deepLinkValue
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
    
    private func parseDeepLinkFromKnowGod(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
        
        //  Example from KnowGod primary language:
        //    https://knowgod.com/en/teachmetoshare?icid=gtshare&primaryLanguage=en&liveShareStream=acd9bee66b6057476cee-1612666248
        //  Example from KnowGod primary and parallel language:
        //    https://knowgod.com/de/honorrestored?parallelLanguage=es&icid=gtshare&primaryLanguage=de&liveShareStream=eb6cd3dafaf82b7c07d3-1612666450
        //  Example from Jesus Film Project:
        //    https://knowgod.com/en/kgp/?primaryLanguage=en&parallelLanguage=en&mcId=58263357509938105951208433145336893265
        
        let pathComponents: [String] = incomingUrl.pathComponents
        let toolQuery: ToolQueryParameters? = JsonServices().decodeJsonObject(jsonObject: incomingUrl.queryParameters)
        
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
        
        var primaryLanguageCodes: [String] = toolQuery?.getPrimaryLanguageCodes() ?? Array()
        
        if let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath {
            primaryLanguageCodes.insert(primaryLanguageCodeFromUrlPath, at: 0)
        }
             
        guard let resourceAbbreviation = abbreviationFromUrlPath, !resourceAbbreviation.isEmpty else {
            return nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: toolQuery?.getParallelLanguageCodes() ?? [],
            liveShareStream: toolQuery?.liveShareStream,
            page: pageFromUrlPath,
            pageId: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
    
    private func parseDefaultUrlStructure(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
        
        let pathComponents: [String] = incomingUrl.pathComponents
        let toolQuery: ToolQueryParameters? = JsonServices().decodeJsonObject(jsonObject: incomingUrl.queryParameters)
        
        guard let rootPath = pathComponents.first, rootPath == DeepLinkPathType.tract.rawValue else {
            return nil
        }
        
        guard let resourceAbbreviation = toolQuery?.abbreviation, !resourceAbbreviation.isEmpty else {
            return nil
        }
        
        let page: Int?
        
        if let pageString = toolQuery?.page, let pageInt = Int(pageString) {
            page = pageInt
        }
        else {
            page = nil
        }
        
        let toolDeepLink = ToolDeepLink(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: toolQuery?.getPrimaryLanguageCodes() ?? [],
            parallelLanguageCodes: toolQuery?.getParallelLanguageCodes() ?? [],
            liveShareStream: toolQuery?.liveShareStream,
            page: page,
            pageId: nil
        )
        
        return .tool(toolDeepLink: toolDeepLink)
    }
}
