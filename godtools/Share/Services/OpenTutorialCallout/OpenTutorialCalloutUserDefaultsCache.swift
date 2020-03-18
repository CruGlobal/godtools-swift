//
//  OpenTutorialCalloutUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialCalloutUserDefaultsCache: OpenTutorialCalloutCacheType {
    
    private let keyOpenTutorialCalloutDisabled: String = "keyOpenTutorialCalloutDisabled"
    
    let openTutorialCalloutDisabledSignal: Signal = Signal()
    
    var openTutorialCalloutEnabled: Bool {
        return !openTutorialCalloutDisabled
    }
    
    var openTutorialCalloutDisabled: Bool {
        return defaults.object(forKey: keyOpenTutorialCalloutDisabled) as? Bool ?? false
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func enableOpenTutorialCallout() {
        defaults.set(nil, forKey: keyOpenTutorialCalloutDisabled)
        defaults.synchronize()
    }
    
    func disableOpenTutorialCallout() {
        defaults.set(true, forKey: keyOpenTutorialCalloutDisabled)
        defaults.synchronize()
        
        openTutorialCalloutDisabledSignal.accept()
    }
}
