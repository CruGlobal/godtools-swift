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
    
    static func createTract(addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString) -> RealmResource {
        
        return createRealmResource(resourceType: .tract, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id)
    }
    
    static func createLesson(addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString) -> RealmResource {
        
        return createRealmResource(resourceType: .lesson, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id)
    }
    
    static func createRealmResource(resourceType: ResourceType, addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString) -> RealmResource {
        
        let resource: RealmResource = RealmResource()
        resource.id = id
        resource.isHidden = false
        resource.resourceType = resourceType.rawValue
        
        for language in addLanguages {
            
            guard let realmLanguage = fromLanguages.first(where: { $0.code == language.rawValue }) else {
                continue
            }
            
            resource.addLanguage(language: realmLanguage)
        }
        
        return resource
    }
}
