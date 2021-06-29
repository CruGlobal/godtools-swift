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
        
        case .url(let incomingUrl):
            return parseDeepLinkFromUrl(incomingUrl: incomingUrl)
        default:
            return nil
        }
    }
    
    private func parseDeepLinkFromUrl(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
        // Example url:
        //  https://godtoolsapp.com/article/aem?uri=https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-/godtools
        
        let pathComponents: [String] = incomingUrl.pathComponents
        
        guard pathComponents.count >= 2, pathComponents[0] == "article", pathComponents[1] == "aem"  else {
            return nil
        }
                
        let queryParameters: [String: Any] = incomingUrl.queryParameters
        
        let articleURIFromURL: String? = queryParameters["uri"] as? String
        
        guard let articleURI = articleURIFromURL else {
            return nil
        }
        
        return .article(articleURI: articleURI)
    }
}
