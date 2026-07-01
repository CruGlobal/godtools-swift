//
//  GetAccountStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetAccountStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let dateService: DateServiceInterface
    
    init(localizationServices: LocalizationServicesInterface, dateService: DateServiceInterface) {
        self.localizationServices = localizationServices
        self.dateService = dateService
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AccountStringsDomainModel {
        
        let localeId: String = appLanguage.localeId
        
        let strings = AccountStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountNavTitle.key),
            activityButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityTitle.key),
            myActivitySectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivitySectionTitle.key),
            badgesSectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountBadgesSectionTitle.key),
            globalActivityButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountGlobalActivityTitle.key),
            globalAnalyticsTitle: getGlobalAnalyticsTitle(localeId: localeId)
        )
        
        return strings
    }
    
    private func getGlobalAnalyticsTitle(localeId: BCP47LanguageIdentifier) -> String {
    
        let localizedGlobalActivityTitle = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: localeId,
            key: LocalizableStringKeys.accountActivityGlobalAnalyticsHeaderTitle.key
        )
                
        let currentYear: Int? = dateService.getCurrentYear(options: CalendarOptions(localeId: localeId))
                
        if let year = currentYear {
            return "\(year) \(localizedGlobalActivityTitle)"
        }
        else {
            return localizedGlobalActivityTitle
        }
    }
}
