//
//  MockRealmResource.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockRealmResource {
    
    static func createTract(addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", isHidden: Bool = false) -> RealmResource {
        
        return createRealmResource(resourceType: .tract, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id, attrDefaultLocale: attrDefaultLocale, attrCategory: attrCategory, isHidden: isHidden)
    }
    
    static func createLesson(addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", isHidden: Bool = false) -> RealmResource {
        
        return createRealmResource(resourceType: .lesson, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id, attrDefaultLocale: attrDefaultLocale, attrCategory: attrCategory, isHidden: isHidden)
    }
    
    static func createRealmResource(resourceType: ResourceType, addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString, attrDefaultLocale: String = "", attrCategory: String = "", isHidden: Bool = false) -> RealmResource {
        
        let resource: RealmResource = RealmResource()
        resource.attrCategory = attrCategory
        resource.attrDefaultLocale = attrDefaultLocale
        resource.id = id
        resource.isHidden = isHidden
        resource.resourceType = resourceType.rawValue
        
        Self.addLanguagesToResource(resource: resource, addLanguages: addLanguages, fromLanguages: fromLanguages)

        return resource
    }
    
    static func addLanguagesToResource(resource: RealmResource, addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage]) {
        
        for language in addLanguages {
            
            guard let realmLanguage = fromLanguages.first(where: { $0.code == language.rawValue }) else {
                continue
            }
            
            resource.addLanguage(language: realmLanguage)
        }
    }
}
