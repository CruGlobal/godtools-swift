//
//  MockResourcesRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockResourcesRepository {
    
    static func getTract(addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString) -> RealmResource {
        
        return getRealmResource(resourceType: .tract, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id)
    }
    
    static func getLesson(addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString) -> RealmResource {
        
        return getRealmResource(resourceType: .lesson, addLanguages: addLanguages, fromLanguages: fromLanguages, id: id)
    }
    
    static func getRealmResource(resourceType: ResourceType, addLanguages: [LanguageCodeDomainModel], fromLanguages: [RealmLanguage], id: String = UUID().uuidString) -> RealmResource {
        
        let resource: RealmResource = RealmResource()
        resource.id = id
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
