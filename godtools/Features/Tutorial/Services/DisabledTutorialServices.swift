//
//  DisabledTutorialServices.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DisabledTutorialServices: TutorialServicesType {
    
    let disabled: Bool
    
    init(disabled: Bool) {
        self.disabled = disabled
    }
    
    var tutorialIsAvailable: Bool {
        return !disabled
    }
    
    var openTutorialCalloutIsAvailable: Bool {
        return !disabled
    }
    
    func enableOpenTutorialCallout() {
        
    }
    
    func disableOpenTutorialCallout() {
        
    }
}
