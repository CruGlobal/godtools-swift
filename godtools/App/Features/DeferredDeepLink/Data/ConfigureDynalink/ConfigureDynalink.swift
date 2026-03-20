//
//  ConfigureDynalink.swift
//  godtools
//
//  Created by Levi Eggert on 3/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import DynalinksSDK

final class ConfigureDynalink {
        
    init() {

    }
    
    func configure(clientApiKey: String) {
        
        do {
            try Dynalinks.configure(clientAPIKey: clientApiKey)
        }
        catch let error {
            
            assertionFailure("Failed to configure dynalinks with error: \(error)")
        }
    }
}
