//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject, DeepLinkingServiceType {
    
    private let deepLinkParsers: [DeepLinkParserType]
    private let deepLinkObserver: PassthroughValue<ParsedDeepLinkType?> = PassthroughValue()
    private let loggingEnabled: Bool
    
    private var lastNonObservedDeepLink: ParsedDeepLinkType?
    
    required init(deepLinkParsers: [DeepLinkParserType], loggingEnabled: Bool) {
        
        self.deepLinkParsers = deepLinkParsers
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    func addDeepLinkObserver(object: NSObject, onObserve: @escaping PassthroughValue<ParsedDeepLinkType?>.Handler) {
        
        deepLinkObserver.addObserver(object, onObserve: onObserve)
        
        if let lastDeepLink = lastNonObservedDeepLink {
            deepLinkObserver.accept(value: lastDeepLink)
            lastNonObservedDeepLink = nil
        }
    }
    
    func removeDeepLinkObserver(object: NSObject) {
        deepLinkObserver.removeObserver(object)
    }
        
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        if loggingEnabled {
            print("\n DeepLinkingService: parseDeepLink()")
            print("  incomingDeepLink: \(incomingDeepLink)")
        }
                
        for deepLinkParser in deepLinkParsers {
            if let deepLink = deepLinkParser.parse(incomingDeepLink: incomingDeepLink) {
                if deepLinkObserver.numberOfObservers > 0 {
                    deepLinkObserver.accept(value: deepLink)
                }
                else {
                    lastNonObservedDeepLink = deepLink
                }
                return true
            }
        }
        
        return false
    }
}
