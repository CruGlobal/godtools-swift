//
//  GetGlobalActivityThisWeekUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetGlobalActivityThisWeekUseCase: Sendable {
    
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
            .map { (globalAnalyticsChanged: Void) in
                
                return self.getGlobalActivity(appLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private func getGlobalActivity(appLanguage: AppLanguageDomainModel) -> [GlobalActivityDomainModel] {
        
        let globalAnalytics: GlobalAnalyticsDataModel? = self.globalAnalyticsRepository.getGlobalAnalytics()

        guard let dataModel = globalAnalytics else {
            return Array()
        }

        let localeId = appLanguage

        let usersTitleKey: String = LocalizableStringKeys.accountActivityGlobalAnalyticsUsersTitle.key
        let gospelPresentationTitleKey: String = LocalizableStringKeys.accountActivityGlobalAnalyticsGospelPresentationTitle.key
        let launchesTitleKey: String = LocalizableStringKeys.accountActivityGlobalAnalyticsLaunchesTitle.key
        let countriesTitleKey: String = LocalizableStringKeys.accountActivityGlobalAnalyticsCountriesTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                usersTitleKey,
                gospelPresentationTitleKey,
                launchesTitleKey,
                countriesTitleKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        let usersAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.users, translateInLanguage: appLanguage),
            label: strings[usersTitleKey] ?? ""
        )

        let gospelPresentationAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.gospelPresentations, translateInLanguage: appLanguage),
            label: strings[gospelPresentationTitleKey] ?? ""
        )

        let launchesAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.launches, translateInLanguage: appLanguage),
            label: strings[launchesTitleKey] ?? ""
        )

        let countriesAnalytics = GlobalActivityDomainModel(
            count: getTranslatedNumberCount.getTranslatedCount(count: dataModel.countries, translateInLanguage: appLanguage),
            label: strings[countriesTitleKey] ?? ""
        )

        let activityThisWeek: [GlobalActivityDomainModel] = [usersAnalytics, gospelPresentationAnalytics, launchesAnalytics, countriesAnalytics]

        return activityThisWeek
    }
}
