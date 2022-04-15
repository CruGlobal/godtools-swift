//
//  AppsFlyerDeepLinkValueParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppsFlyerDeepLinkValueParser: DeepLinkParserType {
    
    private let appsFlyerComponentsParser: AppsFlyerDeepLinkValueComponentsParser = AppsFlyerDeepLinkValueComponentsParser()
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
                
        switch incomingDeepLink {
        
        case .appsFlyer(let data):
            return parseDeepLinkFromAppsFlyer(data: data)
        
        default:
            return nil
        }
    }
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        return nil
    }
    
    private func parseDeepLinkFromAppsFlyer(data: [AnyHashable: Any]) -> ParsedDeepLinkType? {
         
        guard let deepLinkValue = data["deep_link_value"] as? String else {
            return nil
        }
        
        let deepLinkValueComponents: [String] = deepLinkValue.components(separatedBy: "|")
                
        return appsFlyerComponentsParser.getParsedDeepLink(components: deepLinkValueComponents)
    }
}
