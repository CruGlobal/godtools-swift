//
//  GetGlobalActivityThisWeekRepository.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetGlobalActivityThisWeekRepository: GetGlobalActivityThisWeekRepositoryInterface {
    
    private let globalAnalyticsRepository: GlobalAnalyticsRepository
    private let localizationServices: LocalizationServices
    private let getTranslatedNumberCount: GetTranslatedNumberCount
    
    init(globalAnalyticsRepository: GlobalAnalyticsRepository, localizationServices: LocalizationServices, getTranslatedNumberCount: GetTranslatedNumberCount) {
        
        self.globalAnalyticsRepository = globalAnalyticsRepository
        self.localizationServices = localizationServices
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    func getActivityPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never> {
        
        return globalAnalyticsRepository.getGlobalAnalyticsChangedPublisher()
        .flatMap({ (dataModel: GlobalAnalyticsDataModel?) -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never> in
            
            guard let dataModel = dataModel else {
                
                return Just([])
                    .eraseToAnyPublisher()
            }
            
            let localeId = translateInLanguage
            
            let usersAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.users, translateInLanguage: translateInLanguage),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.users.title")
            )
            
            let gospelPresentationAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.gospelPresentations, translateInLanguage: translateInLanguage),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.gospelPresentation.title")
            )
            
            let launchesAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.launches, translateInLanguage: translateInLanguage),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.launches.title")
            )
            
            let countriesAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getTranslatedNumberCount.getTranslatedCount(count: dataModel.countries, translateInLanguage: translateInLanguage),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.countries.title")
            )
            
            let activityThisWeek: [GlobalActivityThisWeekDomainModel] = [usersAnalytics, gospelPresentationAnalytics, launchesAnalytics, countriesAnalytics]
            
            return Just(activityThisWeek)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
