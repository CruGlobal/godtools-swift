//
//  DynalinkUniversalLinkHandler.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import DynalinksSDK

final class DynalinkUniversalLinkHandler {
    
    private let errorReporting: ErrorReportingInterface
    
    init(errorReporting: ErrorReportingInterface) {
        
        self.errorReporting = errorReporting
    }
    
    func handleUniversalLink(url: URL) async {
        
        do {
            _ = try await Dynalinks.handleUniversalLink(url: url)
        }
        catch let error {
            
            errorReporting.reportError(error: error)
        }
    }
}
