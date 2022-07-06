//
//  GetOptInOnboardingTutorialAvailableUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOptInOnboardingTutorialAvailableUseCase {
    
    private let deviceLanguage: DeviceLanguageType
    
    required init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
    }
        
    func getTutorialIsAvailable() -> Bool {
        
        return deviceLanguage.isEnglish
    }
}
