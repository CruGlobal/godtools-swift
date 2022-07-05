//
//  GetTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class GetTutorialIsAvailableUseCase {
    
    private let deviceLanguage: DeviceLanguageType
    
    required init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
    }
    
    func getTutorialIsAvailable() -> Bool {
        
        return deviceLanguage.isEnglish
    }
}
