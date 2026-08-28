//
//  OnboardingAppLanguageAndCountry.swift
//  godtools
//
//  Created by Levi Eggert on 8/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class OnboardingAppLanguageAndCountry: ObservableObject {
    
    @Published private(set) var appLanguage: AppLanguageListItemDomainModel?
    @Published private(set) var country: LocalizationSettingsCountryListItem?
    
    init() {
        
    }
    
    func setAppLanguage(appLanguage: AppLanguageListItemDomainModel?) {
        self.appLanguage = appLanguage
    }
    
    func setCountry(country: LocalizationSettingsCountryListItem?) {
        self.country = country
    }
}
