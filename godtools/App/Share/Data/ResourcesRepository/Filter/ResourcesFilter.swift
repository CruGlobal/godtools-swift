//
//  ResourcesFilter.swift
//  godtools
//
//  Created by Levi Eggert on 11/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ResourcesFilter {
    
    let category: String?
    let languageCode: BCP47LanguageIdentifier?
    let resourceTypes: [ResourceType]?
    let isHidden: Bool?
    let variants: ResourcesFilterVariant?
    
    init(category: String? = nil, languageCode: BCP47LanguageIdentifier? = nil, resourceTypes: [ResourceType]? = nil, isHidden: Bool? = false, variants: ResourcesFilterVariant? = nil) {
        
        self.category = category
        self.languageCode = languageCode
        self.resourceTypes = resourceTypes
        self.isHidden = isHidden
        self.variants = variants
    }
    
    func getCategoryPredicate() -> NSPredicate? {
        
        guard let category = category, !category.isEmpty else {
            return nil
        }
        
        return NSPredicate(format: "\(#keyPath(RealmResource.attrCategory)) == [c] %@", category.lowercased())
    }
    
    func getLanguageCodePredicate() -> NSPredicate? {
        
        guard let languageCode = languageCode?.lowercased(), !languageCode.isEmpty else {
            return nil
        }
        
        let subQuery: String = "SUBQUERY(languages, $language, $language.code == [c] \"\(languageCode)\").@count > 0"
        
        return NSPredicate(format: subQuery)
    }
    
    func getResourceTypesPredicate() -> NSPredicate? {
        
        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else {
            return nil
        }
        
        let resourceTypesValues: [String] = resourceTypes.map({$0.rawValue.lowercased()})
        
        return NSPredicate(format: "\(#keyPath(RealmResource.resourceType)) IN %@", resourceTypesValues)
    }
    
    func getIsHiddenPredicate() -> NSPredicate? {
        
        guard let isHidden = isHidden else {
            return nil
        }
        
        return NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: isHidden))
    }
    
    func getVariantsPredicate() -> NSPredicate? {
        
        guard let variants = variants else {
            return nil
        }
        
        switch variants {
        case .isNotVariant:
            return NSPredicate(format: "\(#keyPath(RealmResource.isVariant)) == %@", NSNumber(value: false))
            
        case .isVariant:
            return NSPredicate(format: "\(#keyPath(RealmResource.isVariant)) == %@", NSNumber(value: true))
            
        case .isDefaultVariant:
            let isVariantFilter = NSPredicate(format: "\(#keyPath(RealmResource.isVariant)) == %@", NSNumber(value: true))
            let isDefaultVariantFilter = NSPredicate(format: "\(#keyPath(RealmResource.id)) == metatool.defaultVariantId")
                                                
            return NSCompoundPredicate(andPredicateWithSubpredicates: [isVariantFilter, isDefaultVariantFilter])
        }
    }
}
