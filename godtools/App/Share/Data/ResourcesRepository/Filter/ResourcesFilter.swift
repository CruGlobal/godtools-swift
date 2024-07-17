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
    let languageModelId: String?
    let languageModelCode: BCP47LanguageIdentifier?
    let resourceTypes: [ResourceType]?
    let isHidden: Bool?
    let variants: ResourcesFilterVariant?
    
    init(category: String? = nil, languageModelId: String? = nil, languageModelCode: BCP47LanguageIdentifier? = nil, resourceTypes: [ResourceType]? = nil, isHidden: Bool? = false, variants: ResourcesFilterVariant? = nil) {
        
        self.category = category
        self.languageModelId = languageModelId
        self.languageModelCode = languageModelCode
        self.resourceTypes = resourceTypes
        self.isHidden = isHidden
        self.variants = variants
    }
    
    static func getCategoryPredicate(category: String) -> NSPredicate {
        return NSPredicate(format: "\(#keyPath(RealmResource.attrCategory)) == [c] %@", category.lowercased())
    }
    
    func getCategoryPredicate() -> NSPredicate? {
        
        guard let category = category, !category.isEmpty else {
            return nil
        }
        
        return ResourcesFilter.getCategoryPredicate(category: category)
    }
    
    static func getLanguageModelIdPredicate(languageModelId: String) -> NSPredicate {
        
        let subQuery: String = "SUBQUERY(languages, $language, $language.id == [c] \"\(languageModelId)\").@count > 0"
        
        return NSPredicate(format: subQuery)
    }
    
    func getLanguageModelIdPredicate() -> NSPredicate? {
        
        guard let languageModelId = languageModelId, !languageModelId.isEmpty else {
            return nil
        }
        
        return ResourcesFilter.getLanguageModelIdPredicate(languageModelId: languageModelId)
    }
    
    static func getLanguageModelCodePredicate(languageModelCode: BCP47LanguageIdentifier) -> NSPredicate {
        
        let subQuery: String = "SUBQUERY(languages, $language, $language.code == [c] \"\(languageModelCode)\").@count > 0"
        
        return NSPredicate(format: subQuery)
    }
    
    func getLanguageModelCodePredicate() -> NSPredicate? {
        
        guard let languageModelCode = languageModelCode?.lowercased(), !languageModelCode.isEmpty else {
            return nil
        }
        
        return ResourcesFilter.getLanguageModelCodePredicate(languageModelCode: languageModelCode)
    }
    
    static func getResourceTypesPredicate(resourceTypes: [ResourceType]) -> NSPredicate {
        
        let resourceTypesValues: [String] = resourceTypes.map({$0.rawValue.lowercased()})
        
        return NSPredicate(format: "\(#keyPath(RealmResource.resourceType)) IN %@", resourceTypesValues)
    }
    
    func getResourceTypesPredicate() -> NSPredicate? {
        
        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else {
            return nil
        }
        
        return ResourcesFilter.getResourceTypesPredicate(resourceTypes: resourceTypes)
    }
    
    static func getIsHiddenPredicate(isHidden: Bool) -> NSPredicate {
        
        return NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: isHidden))
    }
    
    func getIsHiddenPredicate() -> NSPredicate? {
        
        guard let isHidden = isHidden else {
            return nil
        }
        
        return ResourcesFilter.getIsHiddenPredicate(isHidden: isHidden)
    }
    
    static func getVariantsPredicate(variants: ResourcesFilterVariant) -> NSPredicate {
        
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
    
    func getVariantsPredicate() -> NSPredicate? {
        
        guard let variants = variants else {
            return nil
        }
        
        return ResourcesFilter.getVariantsPredicate(variants: variants)
    }
}
