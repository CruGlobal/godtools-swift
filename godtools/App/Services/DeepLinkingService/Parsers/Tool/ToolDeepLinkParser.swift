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
        
        case .url(let url):
            return parseDeepLinkFromUrl(url: url)
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
    
    private func parseDeepLinkFromUrl(url: URL) -> ParsedDeepLinkType? {
        
        //  Example from KnowGod primary language:
        //    https://knowgod.com/en/teachmetoshare?icid=gtshare&primaryLanguage=en&liveShareStream=acd9bee66b6057476cee-1612666248
        //  Example from KnowGod primary and parallel language:
        //    https://knowgod.com/de/honorrestored?parallelLanguage=es&icid=gtshare&primaryLanguage=de&liveShareStream=eb6cd3dafaf82b7c07d3-1612666450
        //  Example from Jesus Film Project:
        //    https://knowgod.com/en/kgp/?primaryLanguage=en&parallelLanguage=en&mcId=58263357509938105951208433145336893265
        
        guard url.containsDeepLinkHost(deepLinkHost: .knowGod) else {
            return nil
        }
        
        var primaryLanguageCodeFromUrlPath: String?
        var resourceAbbreviationFromUrlPath: String?
        var pageFromUrlPath: Int?
        
        let pathComponents: [String] = url.pathComponents.filter({$0 != "/"})
        
        if pathComponents.count > 0 {
            primaryLanguageCodeFromUrlPath = pathComponents[0]
        }
        
        if pathComponents.count > 1 {
            resourceAbbreviationFromUrlPath = pathComponents[1]
        }
        
        if pathComponents.count > 2, let pageIntegerValue = Int(pathComponents[2]) {
            pageFromUrlPath = pageIntegerValue
        }
        
        let queryResult: Result<ToolQueryParameters?, Error> = JsonServices().decodeUrlQuery(url: url)
        let toolQueryParameters: ToolQueryParameters?
        
        switch queryResult {
        case .success(let queryParameters):
            toolQueryParameters = queryParameters
        case .failure( _):
            toolQueryParameters = nil
        }
        
        var primaryLanguageCodes: [String] = toolQueryParameters?.getPrimaryLanguageCodes() ?? Array()
        let parallelLanguageCodes: [String] = toolQueryParameters?.getParallelLanguageCodes() ?? Array()
        
        if let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath {
            primaryLanguageCodes.insert(primaryLanguageCodeFromUrlPath, at: 0)
        }
        
        if primaryLanguageCodes.isEmpty {
            primaryLanguageCodes = ["en"]
        }
                
        guard let resourceAbbreviation = resourceAbbreviationFromUrlPath, !resourceAbbreviation.isEmpty else {
            return nil
        }
        
        return .tool(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: parallelLanguageCodes,
            liveShareStream: toolQueryParameters?.liveShareStream,
            page: pageFromUrlPath
        )
    }
}
