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
    
    func getGlobalActivityPublisher() -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never> {
        
        return globalAnalyticsRepository.getGlobalAnalyticsChangedPublisher()
            .flatMap({ (dataModel: MobileContentGlobalAnalyticsDataModel?) -> AnyPublisher<[GlobalActivityThisWeekDomainModel], Never> in
                
                guard let dataModel = dataModel else {
                    
                    return Just([])
                        .eraseToAnyPublisher()
                }
                
                let usersAnalytics = GlobalActivityThisWeekDomainModel(
                    count: self.getFormattedCount(count: dataModel.data.attributes.users),
                    label: self.localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.users.title")
                )
                
                let gospelPresentationAnalytics = GlobalActivityThisWeekDomainModel(
                    count: self.getFormattedCount(count: dataModel.data.attributes.gospelPresentations),
                    label: self.localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.gospelPresentation.title")
                )
                
                let launchesAnalytics = GlobalActivityThisWeekDomainModel(
                    count: self.getFormattedCount(count: dataModel.data.attributes.launches),
                    label: self.localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.launches.title")
                )
                
                let countriesAnalytics = GlobalActivityThisWeekDomainModel(
                    count: self.getFormattedCount(count: dataModel.data.attributes.countries),
                    label: self.localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.countries.title")
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
