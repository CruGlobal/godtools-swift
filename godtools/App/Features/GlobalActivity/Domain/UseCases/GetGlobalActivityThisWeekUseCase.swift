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
    
    init(globalAnalyticsRepository: GlobalAnalyticsRepository, localizationServices: LocalizationServicesInterface, getTranslatedNumberCount: GetTranslatedNumberCount) {
        
        self.globalAnalyticsRepository = globalAnalyticsRepository
        self.localizationServices = localizationServices
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[GlobalActivityDomainModel], Error> {
        
        return globalAnalyticsRepository
            .getGlobalAnalyticsChangedPublisher(
                requestPriority: .high
            )
            .map { (dataModel: GlobalAnalyticsDataModel?) in
                
                guard let dataModel = dataModel else {
                    return Array()
                }
                
                let localeId = appLanguage
                
                let usersAnalytics = GlobalActivityDomainModel(
                    count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.users, translateInLanguage: appLanguage),
                    label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.users.title")
                )
                
                let gospelPresentationAnalytics = GlobalActivityDomainModel(
                    count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.gospelPresentations, translateInLanguage: appLanguage),
                    label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.gospelPresentation.title")
                )
                
                let launchesAnalytics = GlobalActivityDomainModel(
                    count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.launches, translateInLanguage: appLanguage),
                    label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.launches.title")
                )
                
                let countriesAnalytics = GlobalActivityDomainModel(
                    count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.countries, translateInLanguage: appLanguage),
                    label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.countries.title")
                )
                
                let activityThisWeek: [GlobalActivityDomainModel] = [usersAnalytics, gospelPresentationAnalytics, launchesAnalytics, countriesAnalytics]
                
                return activityThisWeek
            }
            .eraseToAnyPublisher()
    }
}
