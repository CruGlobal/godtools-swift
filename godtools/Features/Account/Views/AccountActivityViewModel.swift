//
//  AccountActivityViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountActivityViewModel: AccountActivityViewModelType {
    
    let globalActivityAnalytics: ObservableValue<[GlobalAnalytics]> = ObservableValue(value: [])
    
    required init(globalActivityServices: GlobalActivityServicesType) {
        
        globalActivityServices.getGlobalAnalytics { [weak self] (result: Result<[GlobalAnalytics], Error>) in
            switch result {
            case .success(let globalAnalytics):
                self?.globalActivityAnalytics.accept(value: globalAnalytics)
            case .failure(let error):
                break
            }
        }
    }
}
