//
//  OpenTutorialCalloutUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OpenTutorialCalloutUserDefaultsCache: OpenTutorialCalloutCacheType {
    
    let openTutorialCalloutDisabledSignal: Signal = Signal()
    
    var openTutorialCalloutEnabled: Bool {
        return !openTutorialCalloutDisabled
    }
    
    var openTutorialCalloutDisabled: Bool {
        return defaults.object(forKey: keyOpenTutorialCalloutDisabled) as? Bool ?? false
    }
    
    private var keyOpenTutorialCalloutDisabled: String {
        return "keyOpenTutorialCalloutDisabled"
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    init(getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase) {
        if getTutorialIsAvailableUseCase.getTutorialIsAvailable() == false {
            
            disableOpenTutorialCallout()
        }
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
