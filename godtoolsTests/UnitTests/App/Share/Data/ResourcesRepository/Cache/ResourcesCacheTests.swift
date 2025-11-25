//
//  ResourcesCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift
import SwiftData

struct ResourcesCacheTests {

    @Test()
    func getLessons() async throws {
        
        let expectedLessonCount: Int = 4
        
        let realmResourcesCache = getResourcesCache(swiftPersistenceIsEnabled: false)
        
        #expect(realmResourcesCache.getLessonsCount() == expectedLessonCount)
        
        let resourcesCache = getResourcesCache(swiftPersistenceIsEnabled: true)
        
        #expect(resourcesCache.getLessonsCount() == expectedLessonCount)
    }
}

extension ResourcesCacheTests {
    
    private func getResourcesCache(swiftPersistenceIsEnabled: Bool) -> ResourcesCache {
        
        if #available(iOS 17.4, *), swiftPersistenceIsEnabled {
            TempSharedSwiftDatabase.shared.setDatabase(
                swiftDatabase: getSwiftDatabase()
            )
        }
        
        let realmDatabase: RealmDatabase = getRealmDatabase()
        
        let trackDownloadedTranslationsRepository = TrackDownloadedTranslationsRepository(
            cache: TrackDownloadedTranslationsCache(
                realmDatabase: realmDatabase
            )
        )
        
        return ResourcesCache(
            realmDatabase: realmDatabase,
            trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository,
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
    
    private func getLessonId(id: Int) -> String {
        return "lesson_" + "\(id)"
    }
    
    private func getTractId(id: Int) -> String {
        return "tract_" + "\(id)"
    }
    
    private func getLanguageId(id: Int) -> String {
        return "language_" + "\(id)"
    }
}

// MARK: - RealmDatabase

extension ResourcesCacheTests {
    
    private func getRealmEnglishLanguage() -> RealmLanguage {
        return MockRealmLanguage.createLanguage(language: .english, name: "english", id: getLanguageId(id: 0))
    }
    
    private func getRealmLessons() -> [RealmResource] {
        
        let english = getRealmEnglishLanguage()
        
        let lesson_0 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 0)))
        MockRealmResource.addLanguagesToResource(resource: lesson_0, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_1 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 1)))
        MockRealmResource.addLanguagesToResource(resource: lesson_1, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_2 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 2)))
        MockRealmResource.addLanguagesToResource(resource: lesson_2, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_3 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 3)))
        MockRealmResource.addLanguagesToResource(resource: lesson_3, addLanguages: [.english], fromLanguages: [english])
                
        // hidden
        let lesson_4 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 4), isHidden: true))
        MockRealmResource.addLanguagesToResource(resource: lesson_4, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_5 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 5), isHidden: true))
        MockRealmResource.addLanguagesToResource(resource: lesson_5, addLanguages: [.english], fromLanguages: [english])
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5]
    }
    
    private func getRealmTracts() -> [RealmResource] {
        
        let english = getRealmEnglishLanguage()
        
        let tract_0 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 0)))
        MockRealmResource.addLanguagesToResource(resource: tract_0, addLanguages: [.english], fromLanguages: [english])
        
        let tract_1 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 1)))
        MockRealmResource.addLanguagesToResource(resource: tract_1, addLanguages: [.english], fromLanguages: [english])
        
        let tract_2 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 2)))
        MockRealmResource.addLanguagesToResource(resource: tract_2, addLanguages: [.english], fromLanguages: [english])
        
        let tract_3 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 3)))
        MockRealmResource.addLanguagesToResource(resource: tract_3, addLanguages: [.english], fromLanguages: [english])
        
        let tract_4 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 4)))
        MockRealmResource.addLanguagesToResource(resource: tract_4, addLanguages: [.english], fromLanguages: [english])
        
        let tract_5 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 5)))
        MockRealmResource.addLanguagesToResource(resource: tract_5, addLanguages: [.english], fromLanguages: [english])
    
        return [tract_0, tract_1, tract_2, tract_3, tract_4, tract_5]
    }
    
    private func getRealmResources() -> [RealmResource] {
        
        return getRealmLessons() + getRealmTracts()
    }
    
    private func getRealmDatabaseObjects() -> [Object] {
        return getRealmResources()
    }
    
    private func getRealmDatabase() -> RealmDatabase {
        return TestsInMemoryRealmDatabase(
            addObjectsToDatabase: getRealmDatabaseObjects()
        )
    }
}

// MARK: - SwiftDatabase

extension ResourcesCacheTests {
    
    @available(iOS 17.4, *)
    private func getEnglishLanguage() -> SwiftLanguage {
        return SwiftLanguage.createNewFrom(
            interface: getRealmEnglishLanguage()
        )
    }
    
    @available(iOS 17.4, *)
    private func getLessons() -> [SwiftResource] {
        
        let english = getEnglishLanguage()
        
        let lesson_0 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 0)))
        MockSwiftResource.addLanguagesToResource(resource: lesson_0, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_1 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 1)))
        MockSwiftResource.addLanguagesToResource(resource: lesson_1, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_2 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 2)))
        MockSwiftResource.addLanguagesToResource(resource: lesson_2, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_3 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 3)))
        MockSwiftResource.addLanguagesToResource(resource: lesson_3, addLanguages: [.english], fromLanguages: [english])
                
        // hidden
        let lesson_4 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 4), isHidden: true))
        MockSwiftResource.addLanguagesToResource(resource: lesson_4, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_5 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 5), isHidden: true))
        MockSwiftResource.addLanguagesToResource(resource: lesson_5, addLanguages: [.english], fromLanguages: [english])
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5]
    }
    
    @available(iOS 17.4, *)
    private func getTracts() -> [SwiftResource] {
        
        let english = getEnglishLanguage()
        
        let tract_0 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 0)))
        MockSwiftResource.addLanguagesToResource(resource: tract_0, addLanguages: [.english], fromLanguages: [english])
        
        let tract_1 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 1)))
        MockSwiftResource.addLanguagesToResource(resource: tract_1, addLanguages: [.english], fromLanguages: [english])
        
        let tract_2 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 2)))
        MockSwiftResource.addLanguagesToResource(resource: tract_2, addLanguages: [.english], fromLanguages: [english])
        
        let tract_3 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 3)))
        MockSwiftResource.addLanguagesToResource(resource: tract_3, addLanguages: [.english], fromLanguages: [english])
        
        let tract_4 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 4)))
        MockSwiftResource.addLanguagesToResource(resource: tract_4, addLanguages: [.english], fromLanguages: [english])
        
        let tract_5 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 5)))
        MockSwiftResource.addLanguagesToResource(resource: tract_5, addLanguages: [.english], fromLanguages: [english])
    
        return [tract_0, tract_1, tract_2, tract_3, tract_4, tract_5]
    }
    
    @available(iOS 17.4, *)
    private func getResources() -> [SwiftResource] {
        
        return getLessons() + getTracts()
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any IdentifiableSwiftDataObject] {
        return getResources()
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabase() -> SwiftDatabase {
        return TestsInMemorySwiftDatabase(
            addObjectsToDatabase: getSwiftDatabaseObjects()
        )
    }
}
