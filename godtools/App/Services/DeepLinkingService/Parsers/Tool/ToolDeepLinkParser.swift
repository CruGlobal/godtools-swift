//
//  ToolDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolDeepLinkParser: DeepLinkParserType {
    
    let supportedUrlHosts: [DeepLinkHostType] = [.godToolsApp, .knowGod]
    let supportedUrlSchemes: [DeepLinkSchemeType] = [.godtools]
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
                
        switch incomingDeepLink {
        
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
        
        case .url(let url):
            
            if url.containsDeepLinkHost(deepLinkHost: .knowGod) {
                return parseDeepLinkFromKnowGod(url: url)
            }
            
            return parseDefaultUrlStructure(url: url)
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
        
        return .tool(resourceAbbreviation: resourceAbbreviation, primaryLanguageCodes: Array(), parallelLanguageCodes: Array(), liveShareStream: nil, page: nil)
    }
    
    private func parseDeepLinkFromKnowGod(url: URL) -> ParsedDeepLinkType? {
        
        //  Example from KnowGod primary language:
        //    https://knowgod.com/en/teachmetoshare?icid=gtshare&primaryLanguage=en&liveShareStream=acd9bee66b6057476cee-1612666248
        //  Example from KnowGod primary and parallel language:
        //    https://knowgod.com/de/honorrestored?parallelLanguage=es&icid=gtshare&primaryLanguage=de&liveShareStream=eb6cd3dafaf82b7c07d3-1612666450
        //  Example from Jesus Film Project:
        //    https://knowgod.com/en/kgp/?primaryLanguage=en&parallelLanguage=en&mcId=58263357509938105951208433145336893265
        
        let pathComponents: [String] = getUrlPathComponents(url: url)
        let toolQuery: ToolQueryParameters? = getDecodedUrlQuery(url: url)
        
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
        
        return .tool(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: toolQuery?.getParallelLanguageCodes() ?? [],
            liveShareStream: toolQuery?.liveShareStream,
            page: pageFromUrlPath
        )
    }
    
    private func parseDefaultUrlStructure(url: URL) -> ParsedDeepLinkType? {
        
        let pathComponents: [String] = getUrlPathComponents(url: url)
        let toolQuery: ToolQueryParameters? = getDecodedUrlQuery(url: url)
        
        guard let rootPath = pathComponents.first, rootPath == "tract" else {
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
        
        return .tool(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: toolQuery?.getPrimaryLanguageCodes() ?? [],
            parallelLanguageCodes: toolQuery?.getParallelLanguageCodes() ?? [],
            liveShareStream: toolQuery?.liveShareStream,
            page: page
        )
    }
}
