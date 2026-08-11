//
//  GetGlobalActivityThisWeekUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetGlobalActivityThisWeekUseCase {
    
    private let globalAnalyticsRepository: GlobalAnalyticsRepository
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedNumberCount: GetTranslatedNumberCount
    
    init(
        globalAnalyticsRepository: GlobalAnalyticsRepository,
        localizationServices: LocalizationServicesInterface,
        getTranslatedNumberCount: GetTranslatedNumberCount
    ) {
        
        self.globalAnalyticsRepository = globalAnalyticsRepository
        self.localizationServices = localizationServices
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[GlobalActivityDomainModel], Error> {

        return globalAnalyticsRepository
            .observeCollectionChangesPublisher()
            .flatMap { (globalAnalyticsChanged: Void) -> AnyPublisher<[GlobalActivityDomainModel], Error> in

                return AnyPublisher() {

                    return await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async -> [GlobalActivityDomainModel] {
        
        let globalAnalytics: GlobalAnalyticsDataModel? = self.globalAnalyticsRepository.getGlobalAnalytics()

        guard let dataModel = globalAnalytics else {
            return Array()
        }

        let localeId = appLanguage

        let usersAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.users, translateInLanguage: appLanguage),
            label: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityGlobalAnalyticsUsersTitle.key)
        )

        let gospelPresentationAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.gospelPresentations, translateInLanguage: appLanguage),
            label: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityGlobalAnalyticsGospelPresentationTitle.key)
        )

        let launchesAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.launches, translateInLanguage: appLanguage),
            label: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityGlobalAnalyticsLaunchesTitle.key)
        )

        let countriesAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.countries, translateInLanguage: appLanguage),
            label: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.accountActivityGlobalAnalyticsCountriesTitle.key)
        )

        let activityThisWeek: [GlobalActivityDomainModel] = [usersAnalytics, gospelPresentationAnalytics, launchesAnalytics, countriesAnalytics]

        return activityThisWeek
    }
}
