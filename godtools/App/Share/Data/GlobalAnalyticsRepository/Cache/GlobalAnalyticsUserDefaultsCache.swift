//
//  GlobalAnalyticsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

struct GlobalAnalyticsUserDefaultsCache {
    
    init() {
        
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func setAttributeValue(attribute: GlobalAnalyticsAttributeType, value: Int) {
        defaults.set(value, forKey: attribute.rawValue)
    }
    
    private func getAttributeValue(attribute: GlobalAnalyticsAttributeType) -> Int? {
        return defaults.object(forKey: attribute.rawValue) as? Int
    }
    
    func getGlobalAnalytics() -> MobileContentGlobalAnalyticsDataModel? {
          
        if let users = getAttributeValue(attribute: .users),
            let countries = getAttributeValue(attribute: .countries),
            let launches = getAttributeValue(attribute: .launches),
            let gospelPresentations = getAttributeValue(attribute: .gospelPresentations) {
            
            let attributes = MobileContentGlobalAnalyticsDataModel.Data.Attributes(
                users: users,
                countries: countries,
                launches: launches,
                gospelPresentations: gospelPresentations
            )
            
            return MobileContentGlobalAnalyticsDataModel(
                data: MobileContentGlobalAnalyticsDataModel.Data(
                    id: "",
                    type: "",
                    attributes: attributes
                )
            )
        }
        
        return nil
    }
    
    func getGlobalAnalyticsPublisher() -> AnyPublisher<MobileContentGlobalAnalyticsDataModel?, Never> {
        
        return Just(getGlobalAnalytics())
            .eraseToAnyPublisher()
    }
    
    func storeGlobalAnalyticsPublisher(globalAnalytics: MobileContentGlobalAnalyticsDataModel) -> AnyPublisher<MobileContentGlobalAnalyticsDataModel, Never> {
        
        let attributes = globalAnalytics.data.attributes
                
        setAttributeValue(attribute: .users, value: attributes.users)
        setAttributeValue(attribute: .countries, value: attributes.countries)
        setAttributeValue(attribute: .launches, value: attributes.launches)
        setAttributeValue(attribute: .gospelPresentations, value: attributes.gospelPresentations)
        
        defaults.synchronize()
        
        return Just(globalAnalytics)
            .eraseToAnyPublisher()
    }
}
