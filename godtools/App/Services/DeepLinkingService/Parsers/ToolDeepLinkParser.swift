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
    
    private func parseDeepLinkFromUrl(url: URL) -> ParsedDeepLinkType? {
        
        //  Example from KnowGod primary language:
        //    https://knowgod.com/en/teachmetoshare?icid=gtshare&primaryLanguage=en&liveShareStream=acd9bee66b6057476cee-1612666248
        //  Example from KnowGod primary and parallel language:
        //    https://knowgod.com/de/honorrestored?parallelLanguage=es&icid=gtshare&primaryLanguage=de&liveShareStream=eb6cd3dafaf82b7c07d3-1612666450
        //  Example from Jesus Film Project:
        //    https://knowgod.com/en/kgp/?primaryLanguage=en&parallelLanguage=en&mcId=58263357509938105951208433145336893265
        
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
        
        var primaryLanguageCodes: [String] = Array()
        var parallelLanguageCodes: [String] = Array()
        var liveShareStream: String?
        
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
        
        for queryItem in queryItems {
            
            let key: String = queryItem.name
            let value: String? = queryItem.value
                        
            if key == "primaryLanguage", let value = value {
                primaryLanguageCodes = value.components(separatedBy: ",")
            }
            else if key == "parallelLanguage", let value = value {
                parallelLanguageCodes = value.components(separatedBy: ",")
            }
            else if key == "liveShareStream" {
                liveShareStream = value
            }
        }
        
        if let primaryLanguageCodeFromUrlPath = primaryLanguageCodeFromUrlPath {
            primaryLanguageCodes.insert(primaryLanguageCodeFromUrlPath, at: 0)
        }
                
        guard let resourceAbbreviation = resourceAbbreviationFromUrlPath, !resourceAbbreviation.isEmpty, !primaryLanguageCodes.isEmpty else {
            return nil
        }
        
        return .tool(
            resourceAbbreviation: resourceAbbreviation,
            primaryLanguageCodes: primaryLanguageCodes,
            parallelLanguageCodes: parallelLanguageCodes,
            liveShareStream: liveShareStream,
            page: pageFromUrlPath
        )
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        return nil
    }
}
