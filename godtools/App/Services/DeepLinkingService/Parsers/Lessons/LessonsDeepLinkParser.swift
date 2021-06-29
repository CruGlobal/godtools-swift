//
//  LessonsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonsDeepLinkParser: DeepLinkParserType {
        
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
        
        switch incomingDeepLink {
       
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
            
        case .url(let incomingUrl):
            return parseDeepLinkFromUrl(incomingUrl: incomingUrl)
        }
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
        
        return nil
    }
    
    private func parseDeepLinkFromUrl(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
                
        guard let rootPath = incomingUrl.rootPath, rootPath == DeepLinkPathType.lessons.rawValue else {
            return nil
        }
        
        return .lessonsList
    }
}
