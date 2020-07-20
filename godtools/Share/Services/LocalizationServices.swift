//
//  LocalizationServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationServices {
    
    private let fallbackLocalizationResourceNames: [String] = ["Base"]
    
    required init() {
        
    }
    
    var shouldFallbackToBundleIfStringEqualsKey: Bool {
        return !fallbackLocalizationResourceNames.isEmpty
    }
    
    private func bundleForResource(resourceName: String) -> Bundle? {
        
        if !resourceName.isEmpty, let path = Bundle.main.path(forResource: resourceName, ofType: "lproj"), let bundle: Bundle = Bundle(path: path) {
            return bundle
        }
        
        return nil
    }
    
    private func localizedStringForBundle(bundle: Bundle, key: String, value: String?, table: String?) -> String? {
        
        let localizedString: String = bundle.localizedString(forKey: key, value: value, table: table)
        
        if localizedString == key && shouldFallbackToBundleIfStringEqualsKey {
            return nil
        }
        
        return localizedString
    }
    
    func bundleForResourceElseFallbackBundle(resourceName: String) -> Bundle {
        
        if let bundle = bundleForResource(resourceName: resourceName) {
            return bundle
        }
        
        for fallbackResourceName in fallbackLocalizationResourceNames {
            if let fallbackBundle = bundleForResource(resourceName: fallbackResourceName) {
                return fallbackBundle
            }
        }
        
        return Bundle.main
    }

    func stringForLocalizationResource(resourceName: String, key: String, value: String? = nil, table: String? = nil) -> String {
        
        return stringForBundle(
            bundle: bundleForResourceElseFallbackBundle(resourceName: resourceName),
            key: key,
            value: value,
            table: table
        )
    }
    
    func stringForMainBundle(key: String, value: String? = nil, table: String? = nil) -> String {
        
        return stringForBundle(
            bundle: Bundle.main,
            key: key,
            value: value,
            table: table
        )
    }
    
    func stringForBundle(bundle: Bundle, key: String, value: String? = nil, table: String? = nil) -> String {
        
        if let localizedString = localizedStringForBundle(bundle: bundle, key: key, value: value, table: table) {
            return localizedString
        }
        
        for fallbackResourceName in fallbackLocalizationResourceNames {
            
            if let fallbackBundle = bundleForResource(resourceName: fallbackResourceName),
                let fallbackLocalizedString = localizedStringForBundle(bundle: fallbackBundle, key: key, value: value, table: table) {
                
                return fallbackLocalizedString
            }
        }
        
        return Bundle.main.localizedString(forKey: key, value: value, table: table)
    }
}
