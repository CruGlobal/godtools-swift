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
    private let loggingEnabled: Bool
        
    let completed: ObservableValue<ParsedDeepLinkType?> = ObservableValue(value: nil)
    
    required init(deepLinkParsers: [DeepLinkParserType], loggingEnabled: Bool) {
        
        self.deepLinkParsers = deepLinkParsers
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
        
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        if loggingEnabled {
            print("\n DeepLinkingService: parseDeepLink()")
            print("  incomingDeepLink: \(incomingDeepLink)")
        }
                
        for deepLinkParser in deepLinkParsers {
            if let deepLink = deepLinkParser.parse(incomingDeepLink: incomingDeepLink) {
                completed.accept(value: deepLink)
                return true
            }
        }
        
        completed.accept(value: nil)
        return false
    }
}
