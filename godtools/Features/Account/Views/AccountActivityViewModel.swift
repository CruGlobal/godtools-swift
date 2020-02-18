//
//  AccountActivityViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountActivityViewModel: AccountActivityViewModelType {
    
    let globalActivityAttributes: ObservableValue<[GlobalActivityAttribute]> = ObservableValue(value: [])
    
    required init(globalActivityServices: GlobalActivityServicesType) {
                
        _ = globalActivityServices.getGlobalAnalytics { [weak self] (result: Result<GlobalAnalytics?, Error>) in
            switch result {
            case .success(let globalAnalytics):
                if let globalAnalytics = globalAnalytics {
                    self?.globalActivityAttributes.accept(value: [
                        GlobalActivityAttribute(activityType: .users, count: globalAnalytics.data.attributes.users),
                        GlobalActivityAttribute(activityType: .gospelPresentation, count: globalAnalytics.data.attributes.gospelPresentations),
                        GlobalActivityAttribute(activityType: .launches, count: globalAnalytics.data.attributes.launches),
                        GlobalActivityAttribute(activityType: .countries, count: globalAnalytics.data.attributes.countries)
                    ])
                }
            case .failure( _):
                break
            }
        }
    }
}
