//
//  GetAccountInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAccountInterfaceStringsRepository: GetAccountInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<AccountInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage.localeId
        
        let interfaceStrings = AccountInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.Account.navTitle.rawValue),
            activityButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.Account.activityButtonTitle.rawValue),
            myActivitySectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.Account.activitySectionTitle.rawValue),
            badgesSectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.Account.badgesSectionTitle.rawValue),
            globalActivityButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.Account.globalActivityButtonTitle.rawValue),
            globalAnalyticsTitle: getGlobalAnalyticsTitle(localeId: localeId)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getGlobalAnalyticsTitle(localeId: BCP47LanguageIdentifier) -> String {
    
        let localizedGlobalActivityTitle = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: MenuStringKeys.Account.globalAnalyticsTitle.rawValue)
        
        let todaysDate: Date = Date()
        let todaysYearComponents: DateComponents = Calendar.current.dateComponents([.year], from: todaysDate)
                
        if let year = todaysYearComponents.year {
            return "\(year) \(localizedGlobalActivityTitle)"
        }
        else {
            return localizedGlobalActivityTitle
        }
    }
}
