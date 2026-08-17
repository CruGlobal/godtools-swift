//
//  GetAccountStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetAccountStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    private let dateService: DateServiceInterface
    
    init(localizationServices: LocalizationServicesInterface, dateService: DateServiceInterface) {
        self.localizationServices = localizationServices
        self.dateService = dateService
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AccountStringsDomainModel {

        let localeId: String = appLanguage.localeId

        let navTitleKey: String = LocalizableStringKeys.accountNavTitle.key
        let activityButtonTitleKey: String = LocalizableStringKeys.accountActivityTitle.key
        let myActivitySectionTitleKey: String = LocalizableStringKeys.accountActivitySectionTitle.key
        let badgesSectionTitleKey: String = LocalizableStringKeys.accountBadgesSectionTitle.key
        let globalActivityButtonTitleKey: String = LocalizableStringKeys.accountGlobalActivityTitle.key
        let globalAnalyticsTitleKey: String = LocalizableStringKeys.accountActivityGlobalAnalyticsHeaderTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey,
                activityButtonTitleKey,
                myActivitySectionTitleKey,
                badgesSectionTitleKey,
                globalActivityButtonTitleKey,
                globalAnalyticsTitleKey
            ],
            fetchOrder: [
                .locale(identifier: localeId),
                .english
            ],
            shouldFallbackToKey: true
        )

        return AccountStringsDomainModel(
            navTitle: strings[navTitleKey] ?? "",
            activityButtonTitle: strings[activityButtonTitleKey] ?? "",
            myActivitySectionTitle: strings[myActivitySectionTitleKey] ?? "",
            badgesSectionTitle: strings[badgesSectionTitleKey] ?? "",
            globalActivityButtonTitle: strings[globalActivityButtonTitleKey] ?? "",
            globalAnalyticsTitle: getGlobalAnalyticsTitle(localeId: localeId, localizedGlobalActivityTitle: strings[globalAnalyticsTitleKey] ?? "")
        )
    }

    private func getGlobalAnalyticsTitle(localeId: BCP47LanguageIdentifier, localizedGlobalActivityTitle: String) -> String {

        let currentYear: Int? = dateService.getCurrentYear(options: CalendarOptions(localeId: localeId))

        if let year = currentYear {
            return "\(year) \(localizedGlobalActivityTitle)"
        }
        else {
            return localizedGlobalActivityTitle
        }
    }
}
