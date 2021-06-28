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
        
        guard url.containsDeepLinkHost(deepLinkHost: .godToolsApp), pathComponents.count >= 2, pathComponents[0] == "article", pathComponents[1] == "aem"  else {
            return nil
        }
        
        var articleURIFromURL: String? = nil
        
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
        
        for queryItem in queryItems {
            let key: String = queryItem.name
            let value: String? = queryItem.value
                        
            if key == "uri", let value = value {
                articleURIFromURL = value
            }
        }
        
        guard let articleURI = articleURIFromURL else { return nil }
        
        return .article(articleURI: articleURI)
    }
}
