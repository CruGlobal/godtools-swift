//
//  OrgCruGodToolsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class OrgCruGodToolsDeepLinkParser: DeepLinkParserType {
    
    private let appsFlyerComponentsParser: AppsFlyerDeepLinkValueComponentsParser = AppsFlyerDeepLinkValueComponentsParser()
    
    required init() {
        
    }
    
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
        
        switch incomingDeepLink {
        case .appsFlyer( _):
            return nil
        case .url(let incomingUrl):
            return parseIncomingUrl(incomingUrl: incomingUrl)
        }
    }
    
    private func parseIncomingUrl(incomingUrl: IncomingDeepLinkUrl) -> ParsedDeepLinkType? {
 
        guard let scheme = incomingUrl.url.scheme else {
            return nil
        }
        
        guard scheme == "org.cru.godtools" else {
            return nil
        }
                
        return appsFlyerComponentsParser.getParsedDeepLink(components: incomingUrl.pathComponents)
    }
}
