//
//  ArticleDeepLinkParser.swift
//  godtools
//
//  Created by Robert Eldredge on 2/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleDeepLinkParser: DeepLinkParserType {
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
        switch incomingDeepLink {
        
        case .url(let url):
            return parseDeepLinkFromUrl(url: url)
        default:
            return nil
        }
    }
    
    private func parseDeepLinkFromUrl(url: URL) -> ParsedDeepLinkType? {
        // Example url:
        //  https://godtoolsapp.com/article/aem?uri=https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-/godtools
        
        let pathComponents: [String] = url.pathComponents.filter({$0 != "/"})
        let urlString = url.absoluteString

        guard url.containsDeepLinkHost(deepLinkHost: .godToolsApp), pathComponents[0] == "article", pathComponents[1] == "aem"  else {
            return nil
        }
        
        var articleURI: String? = nil
        
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
        
        for queryItem in queryItems {
            let key: String = queryItem.name
            let value: String? = queryItem.value
                        
            if key == "uri", let value = value {
               articleURI = value
            }
        }
        
        
        
        
        /*if pathComponents.count > 0 {
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
        
        return .article(
            resourceAbbreviation: resourceAbbreviation,
            translationZipFile: <#T##TranslationZipFileModel#>,
            articleAemImportData: <#T##ArticleAemImportData#>
        )*/
        
        return nil
    }
}
