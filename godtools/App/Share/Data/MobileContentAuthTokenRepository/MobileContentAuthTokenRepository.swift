//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

class MobileContentAuthTokenRepository {
    
    private let api: MobileContentAuthTokenAPI
    private let cache: MobileContentAuthTokenCache
    
    private var cancellables = Set<AnyCancellable>()
    
    init(api: MobileContentAuthTokenAPI, cache: MobileContentAuthTokenCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func refreshAuthToken(oktaAccessToken: OktaAccessToken) {
        
        api.fetchAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
            .sink { completed in
                
                switch completed {
                case .finished:
                    break
                    
                case .failure(let error):
                    
                    assertionFailure("Refresh auth token failed with error: \(error.localizedDescription)")
                }
                
            } receiveValue: { [weak self] authTokenDataModel in
                
                self?.cache.storeAuthToken(authTokenDataModel)
            }
            .store(in: &cancellables)
    }
}
