//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject, DeepLinkingServiceType {
    
    private let manifest: DeepLinkingManifest
    
    let deepLinkObserver: PassthroughValue<ParsedDeepLinkType?> = PassthroughValue()
        
    required init(manifest: DeepLinkingManifest) {
        
        self.manifest = manifest
        
        super.init()
    }
     
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        for parserManifest in manifest.parserManifests {
            
            switch incomingDeepLink {
            
            case .appsFlyer(let data):
                break
            
            case .url(let incomingUrl):
                
                for parserManifestUrl in parserManifest.urls {
                    
                    guard parserManifestUrl.matchesIncomingUrl(incomingUrl: incomingUrl) else {
                        continue
                    }
                    
                    let parser: DeepLinkParserType = parserManifest.parserClass.init()
                    
                    guard let deepLink = parser.parse(pathComponents: incomingUrl.pathComponents, queryParameters: incomingUrl.queryParameters) else {
                        continue
                    }
                    
                    deepLinkObserver.accept(value: deepLink)
                    return true
                }
            }
        }
        
        return false
    }
}
