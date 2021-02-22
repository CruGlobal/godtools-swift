//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject, DeepLinkingServiceType {
    
    private let deepLinkingParsers: DeepLinkParsersContainer = DeepLinkParsersContainer()
    private let loggingEnabled: Bool
        
    let processing: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<ParsedDeepLinkType?> = ObservableValue(value: nil)
    
    required init(loggingEnabled: Bool) {
        
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    //MARK: - Public
    
    func parseDeepLink(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        if loggingEnabled {
            print("\n DeepLinkingService: parseDeepLink()")
            print("  incomingDeepLink: \(incomingDeepLink)")
        }
                
        for deepLinkParser in deepLinkingParsers.parsers {
            if let deepLink = deepLinkParser.parse(incomingDeepLink: incomingDeepLink) {
                completed.accept(value: deepLink)
                return true
            }
        }
        
        completed.accept(value: nil)
        return false
    }
}
