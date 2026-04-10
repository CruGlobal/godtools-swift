//
//  DynalinkDeferredDeepLink.swift
//  godtools
//
//  Created by Levi Eggert on 3/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import DynalinksSDK
import Combine

final class DynalinkDeferredDeepLink {
    
    private let errorReporting: ErrorReportingInterface
    
    init(errorReporting: ErrorReportingInterface) {
        
        self.errorReporting = errorReporting
    }
    
    private func getDeepLinkResult() async throws -> DeepLinkResult {
        
        return try await Dynalinks.checkForDeferredDeepLink()
    }
    
    func getDeepLinkUrl() async -> URL? {
        
        do {
            
            let result: DeepLinkResult = try await getDeepLinkResult()
            
            guard result.matched, let fullUrl = result.link?.fullURL else {
                return nil
            }
            
            return fullUrl
        }
        catch let error {
            
            errorReporting.reportError(error: error)
            
            return nil
        }
    }
    
    func getDeepLinkUrlPublisher() -> AnyPublisher<URL?, Error> {
        return AnyPublisher() {
            return await self.getDeepLinkUrl()
        }
    }
}
