//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class DeepLinkingService {
    
    private let manifest: DeepLinkingManifestInterface
    private let lastParsedDeepLinkSubject: PassthroughSubject<ParsedDeepLinkType?, Never> = PassthroughSubject()
            
    init(manifest: DeepLinkingManifestInterface) {
        
        self.manifest = manifest
    }
    
    var parsedDeepLinkPublisher: AnyPublisher<ParsedDeepLinkType?, Never> {
        return lastParsedDeepLinkSubject.eraseToAnyPublisher()
    }
    
    func parseDeepLink(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType? {
       
        for parserManifest in manifest.parserManifests {
            
            guard let parser = parserManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink) else {
                continue
            }
                        
            let parsedDeepLink: ParsedDeepLinkType?
            
            switch incomingDeepLink {
            
            case .url(let incomingUrl):
                
                guard let urlParser = parser as? DeepLinkUrlParserInterface else {
                    continue
                }
                
                parsedDeepLink = urlParser.parse(url: incomingUrl.url, pathComponents: incomingUrl.pathComponents, queryParameters: incomingUrl.queryParameters)
            }
                        
            guard let deepLink = parsedDeepLink else {
                continue
            }
            
            return deepLink
        }
        
        return nil
    }
     
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        guard let parsedDeepLink = parseDeepLink(incomingDeepLink: incomingDeepLink) else {
            return false
        }
        
        lastParsedDeepLinkSubject.send(parsedDeepLink)
        
        return true
    }
}
