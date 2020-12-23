//
//  AccountActivityViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountActivityViewModel: AccountActivityViewModelType {
    
    private var getGlobalAnalyticsOperation: OperationQueue?
    
    let localizationServices: LocalizationServices
    let globalActivityResults: ObservableValue<GlobalActivityResults> = ObservableValue(value: GlobalActivityResults(isLoading: true, didFail: false, globalActivityAttributes: []))
    let alertMessage: ObservableValue<AlertMessageType?> = ObservableValue(value: nil)
    
    required init(localizationServices: LocalizationServices, globalActivityServices: GlobalActivityServices) {
        
        self.localizationServices = localizationServices
        
        let cachedAttributes: GlobalActivityAnalytics.Data.Attributes? = globalActivityServices.cachedGlobalAnalytics?.data.attributes
        
        let globalActivityAttributes: [GlobalActivityAttribute] = createGlobalActivityAttributes(attributes: cachedAttributes ?? nil)
        
        globalActivityResults.accept(value: GlobalActivityResults(isLoading: true, didFail: false, globalActivityAttributes: globalActivityAttributes))
        
        getGlobalAnalyticsOperation = globalActivityServices.getGlobalAnalytics(complete: { [weak self] (result: Result<GlobalActivityAnalytics?, ResponseError<NoClientApiErrorType>>) in
                        
            switch result {
            
            case .success(let globalActivity):
                
                let attributes = globalActivity?.data.attributes
                let globalActivityAttributes: [GlobalActivityAttribute] = self?.createGlobalActivityAttributes(attributes: attributes) ?? []
                
                self?.globalActivityResults.accept(value: GlobalActivityResults(isLoading: false, didFail: false, globalActivityAttributes: globalActivityAttributes))
            
            case .failure(let error):
                                
                let globalActivityAttributes: [GlobalActivityAttribute] = self?.createGlobalActivityAttributes(attributes: nil) ?? []
                
                self?.globalActivityResults.accept(value: GlobalActivityResults(isLoading: false, didFail: true, globalActivityAttributes: globalActivityAttributes))
                
                if !error.cancelled {
                    self?.alertMessage.accept(value: ResponseErrorAlertMessage(localizationServices: localizationServices, error: error))
                }
            }
        })
    }
    
    deinit {
        getGlobalAnalyticsOperation?.cancelAllOperations()
    }
    
    private func createGlobalActivityAttributes(attributes: GlobalActivityAnalytics.Data.Attributes?) -> [GlobalActivityAttribute] {
        if let attributes = attributes {
            return [
                GlobalActivityAttribute(activityType: .users, count: attributes.users),
                GlobalActivityAttribute(activityType: .gospelPresentation, count: attributes.gospelPresentations),
                GlobalActivityAttribute(activityType: .launches, count: attributes.launches),
                GlobalActivityAttribute(activityType: .countries, count: attributes.countries)
            ]
        }
        else {
            return [
                GlobalActivityAttribute(activityType: .users, count: 0),
                GlobalActivityAttribute(activityType: .gospelPresentation, count: 0),
                GlobalActivityAttribute(activityType: .launches, count: 0),
                GlobalActivityAttribute(activityType: .countries, count: 0)
            ]
        }
    }
}
