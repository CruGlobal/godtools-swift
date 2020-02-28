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
    
    let globalActivityAttributes: ObservableValue<[GlobalActivityAttribute]> = ObservableValue(value: [])
    let isLoadingGlobalActivity: ObservableValue<Bool> = ObservableValue(value: false)
    let didFailToGetGlobalActivity: ObservableValue<Bool> = ObservableValue(value: false)
    let alertMessage: ObservableValue<AlertMessage?> = ObservableValue(value: nil)
    
    required init(globalActivityServices: GlobalActivityServicesType) {
        
        isLoadingGlobalActivity.accept(value: true)
        globalActivityAttributes.accept(value: createGlobalActivityAttributes(attributes: nil))
        
        getGlobalAnalyticsOperation = globalActivityServices.getGlobalAnalytics(complete: { [weak self] (response: RequestResponse, result: RequestResult<GlobalActivityAnalytics, RequestClientError>) in
            
            self?.isLoadingGlobalActivity.accept(value: false)
            
            switch result {
            
            case .success(let globalActivity):
                self?.globalActivityAttributes.accept(value: self?.createGlobalActivityAttributes(attributes: globalActivity?.data.attributes) ?? [])
            
            case .failure(let clientError, let error):
                
                self?.didFailToGetGlobalActivity.accept(value: true)
                
                if !response.requestCancelled {
                    self?.alertMessage.accept(
                        value: AlertMessage(
                            title: clientError?.title ?? "",
                            message: clientError?.message ?? error.localizedDescription
                        )
                    )
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
