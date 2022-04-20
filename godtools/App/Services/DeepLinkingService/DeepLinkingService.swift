//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject, DeepLinkingServiceType {
    
    private let manifest: DeepLinkingManifestType
    
    let deepLinkObserver: PassthroughValue<ParsedDeepLinkType?> = PassthroughValue()
        
    required init(manifest: DeepLinkingManifestType) {
        
        self.manifest = manifest
        
        super.init()
    }
     
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        for parserManifest in manifest.parserManifests {
            
            guard parserManifest.matchesIncomingDeepLink(incomingDeepLink: incomingDeepLink) else {
                continue
            }
            
            let parser: DeepLinkParserType = parserManifest.parserClass.init()
            
            let parsedDeepLink: ParsedDeepLinkType?
            
            switch incomingDeepLink {
            
            case .appsFlyer(let data):
                
                guard let appsFlyerParser = parser as? DeepLinkAppsFlyerParserType else {
                    continue
                }
                
                parsedDeepLink = appsFlyerParser.parse(data: data)
            
            case .url(let incomingUrl):
                
                guard let urlParser = parser as? DeepLinkUrlParserType else {
                    continue
                }
                
                parsedDeepLink = urlParser.parse(pathComponents: incomingUrl.pathComponents, queryParameters: incomingUrl.queryParameters)
            }
                        
            guard let deepLink = parsedDeepLink else {
                continue
            }
            
            deepLinkObserver.accept(value: deepLink)
            return true
        }
        
        return false
    }
}
