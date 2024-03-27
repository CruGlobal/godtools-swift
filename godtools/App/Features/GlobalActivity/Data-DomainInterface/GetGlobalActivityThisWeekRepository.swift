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
    private let formatNumberWithCommas: NumberFormatter = NumberFormatter()
    
    init(globalAnalyticsRepository: GlobalAnalyticsRepository, localizationServices: LocalizationServices) {
        
        self.globalAnalyticsRepository = globalAnalyticsRepository
        self.localizationServices = localizationServices
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
                count: self.getFormattedCount(translateInLanguage: translateInLanguage, count: dataModel.users),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.users.title")
            )
            
            let gospelPresentationAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(translateInLanguage: translateInLanguage, count: dataModel.gospelPresentations),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.gospelPresentation.title")
            )
            
            let launchesAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(translateInLanguage: translateInLanguage, count: dataModel.launches),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.launches.title")
            )
            
            let countriesAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(translateInLanguage: translateInLanguage, count: dataModel.countries),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.countries.title")
            )
            
            let activityThisWeek: [GlobalActivityThisWeekDomainModel] = [usersAnalytics, gospelPresentationAnalytics, launchesAnalytics, countriesAnalytics]
            
            return Just(activityThisWeek)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getFormattedCount(translateInLanguage: AppLanguageDomainModel, count: Int) -> String {
        
        formatNumberWithCommas.numberStyle = .decimal
        formatNumberWithCommas.locale = Locale(identifier: translateInLanguage)
        
        return formatNumberWithCommas.string(from: NSNumber(value: count)) ?? ""
    }
}
