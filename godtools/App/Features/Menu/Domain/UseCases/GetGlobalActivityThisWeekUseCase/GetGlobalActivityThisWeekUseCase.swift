//
//  GetGlobalActivityThisWeekUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetGlobalActivityThisWeekUseCase {
    
    private let globalAnalyticsRepository: GlobalAnalyticsRepository
    private let localizationServices: LocalizationServices
    private let formatNumberWithCommas: NumberFormatter = NumberFormatter()
    
    init(globalAnalyticsRepository: GlobalAnalyticsRepository, localizationServices: LocalizationServices) {
        
        self.globalAnalyticsRepository = globalAnalyticsRepository
        self.localizationServices = localizationServices
    }
    
    func getGlobalActivityPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never> {
        
        return Publishers.CombineLatest(
            globalAnalyticsRepository.getGlobalAnalyticsChangedPublisher(),
            appLanguagePublisher
        )
        .flatMap({ (dataModel: GlobalAnalyticsDataModel?, appLanguage: AppLanguageDomainModel) -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never> in
            
            guard let dataModel = dataModel else {
                
                return Just([])
                    .eraseToAnyPublisher()
            }
            
            let localeId = appLanguage
            
            let usersAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(count: dataModel.users),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.users.title")
            )
            
            let gospelPresentationAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(count: dataModel.gospelPresentations),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.gospelPresentation.title")
            )
            
            let launchesAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(count: dataModel.launches),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.launches.title")
            )
            
            let countriesAnalytics = GlobalActivityThisWeekDomainModel(
                count: self.getFormattedCount(count: dataModel.countries),
                label: self.localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "accountActivity.globalAnalytics.countries.title")
            )
            
            let activityThisWeek: [GlobalActivityThisWeekDomainModel] = [usersAnalytics, gospelPresentationAnalytics, launchesAnalytics, countriesAnalytics]
            
            return Just(activityThisWeek)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getFormattedCount(count: Int) -> String {
        
        formatNumberWithCommas.numberStyle = .decimal
        
        return formatNumberWithCommas.string(from: NSNumber(value: count)) ?? ""
    }
}
