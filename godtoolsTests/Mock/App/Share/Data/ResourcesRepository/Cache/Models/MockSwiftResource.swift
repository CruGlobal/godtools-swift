//
//  MockSwiftResource.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

@available(iOS 17.4, *)
class MockSwiftResource {
    
    static func createTract(addLanguages: [LanguageCodeDomainModel], fromLanguages: [SwiftLanguage], id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", isHidden: Bool = false) -> SwiftResource {
        
        return createResource(resourceType: .tract, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id, attrDefaultLocale: attrDefaultLocale, attrCategory: attrCategory, isHidden: isHidden)
    }
    
    static func createLesson(addLanguages: [LanguageCodeDomainModel], fromLanguages: [SwiftLanguage], id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", isHidden: Bool = false) -> SwiftResource {
        
        return createResource(resourceType: .lesson, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id, attrDefaultLocale: attrDefaultLocale, attrCategory: attrCategory, isHidden: isHidden)
    }
    
    static func createResource(resourceType: ResourceType, addLanguages: [LanguageCodeDomainModel], fromLanguages: [SwiftLanguage], id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", isHidden: Bool = false) -> SwiftResource {
        
        let resource = SwiftResource()
        resource.attrCategory = attrCategory
        resource.attrDefaultLocale = attrDefaultLocale
        resource.attrSpotlight = false
        resource.id = id
        resource.isHidden = isHidden
        resource.resourceType = resourceType.rawValue
        
        Self.addLanguagesToResource(resource: resource, addLanguages: addLanguages, fromLanguages: fromLanguages)
        
        return resource
    }
    
    static func addLanguagesToResource(resource: SwiftResource, addLanguages: [LanguageCodeDomainModel], fromLanguages: [SwiftLanguage]) {
        
        for language in addLanguages {
            
            guard let swiftLanguage = fromLanguages.first(where: { $0.code == language.rawValue }) else {
                continue
            }
            
            resource.addLanguage(language: swiftLanguage)
        }
    }
}
