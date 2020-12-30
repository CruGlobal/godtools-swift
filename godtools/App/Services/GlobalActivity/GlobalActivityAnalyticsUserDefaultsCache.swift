//
//  GlobalActivityAnalyticsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalActivityAnalyticsUserDefaultsCache: GlobalActivityAnalyticsCacheType {
    
    enum Attribute: String {
        case users = "users"
        case countries = "countries"
        case launches = "launches"
        case gospelPresentations = "gospel_presentations"
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func setAttributeValue(attribute: Attribute, value: Int) {
        defaults.set(value, forKey: attribute.rawValue)
    }
    
    private func getAttributeValue(attribute: Attribute) -> Int? {
        return defaults.object(forKey: attribute.rawValue) as? Int
    }
    
    func getGlobalActivityAnalytics() -> GlobalActivityAnalytics? {
          
        if let users = getAttributeValue(attribute: .users),
            let countries = getAttributeValue(attribute: .countries),
            let launches = getAttributeValue(attribute: .launches),
            let gospelPresentations = getAttributeValue(attribute: .gospelPresentations) {
            
            let attributes = GlobalActivityAnalytics.Data.Attributes(
                users: users,
                countries: countries,
                launches: launches,
                gospelPresentations: gospelPresentations
            )
            
            return GlobalActivityAnalytics(
                data: GlobalActivityAnalytics.Data(
                    id: "",
                    type: "",
                    attributes: attributes
                )
            )
        }
        
        return nil
    }
    
    func cacheGlobalActivityAnalytics(globalAnalytics: GlobalActivityAnalytics) {
        
        let attributes = globalAnalytics.data.attributes
                
        setAttributeValue(attribute: .users, value: attributes.users)
        setAttributeValue(attribute: .countries, value: attributes.countries)
        setAttributeValue(attribute: .launches, value: attributes.launches)
        setAttributeValue(attribute: .gospelPresentations, value: attributes.gospelPresentations)
        
        defaults.synchronize()
    }
}
