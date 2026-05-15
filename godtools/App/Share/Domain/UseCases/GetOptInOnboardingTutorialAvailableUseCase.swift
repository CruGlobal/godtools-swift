//
//  GetOptInOnboardingTutorialAvailableUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class GetOptInOnboardingTutorialAvailableUseCase {
        
    init() {
        
    }
        
    func execute(appLanguage: AppLanguageDomainModel) -> Bool {
        
        let isAvailable: Bool = appLanguage == LanguageCodeDomainModel.english.value
        
        return isAvailable
    }
}
