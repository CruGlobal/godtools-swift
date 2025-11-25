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
    func getLessonCount() async {
        
        let expectedLessonCount: Int = 7
        
        let realmResourcesCache = getResourcesCache(swiftPersistenceIsEnabled: false)
        
        #expect(realmResourcesCache.getLessonsCount() == expectedLessonCount)
        
        let resourcesCache = getResourcesCache(swiftPersistenceIsEnabled: true)
        
        #expect(resourcesCache.getLessonsCount() == expectedLessonCount)
    }
    
    @Test()
    func getLessons() async {
        
        let expectedLessonIds: [String] = [
            getLessonId(id: 0),
            getLessonId(id: 1),
            getLessonId(id: 2),
            getLessonId(id: 3),
            getLessonId(id: 6),
            getLessonId(id: 7),
            getLessonId(id: 8)
        ]
                
        let realmResourcesCache = getResourcesCache(swiftPersistenceIsEnabled: false)
        let realmLessons = realmResourcesCache.getLessons(filterByLanguageId: nil, sorted: false)
        
        #expect(realmLessons.map {$0.id}.sorted() == expectedLessonIds)
        
        let resourcesCache = getResourcesCache(swiftPersistenceIsEnabled: true)
        let lessons = resourcesCache.getLessons(filterByLanguageId: nil, sorted: false)
        
        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
    }
    
    @Test()
    func getFeaturedLessons() async {
        
        let expectedLessonIds: [String] = [
            getLessonId(id: 6),
            getLessonId(id: 7),
            getLessonId(id: 8)
        ]
                
        let realmResourcesCache = getResourcesCache(swiftPersistenceIsEnabled: false)
        let realmLessons = realmResourcesCache.getFeaturedLessons(sorted: false)
        
        #expect(realmLessons.map {$0.id}.sorted() == expectedLessonIds)
        
        let resourcesCache = getResourcesCache(swiftPersistenceIsEnabled: true)
        let lessons = resourcesCache.getFeaturedLessons(sorted: false)
        
        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
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
    
    private func getEnglishLanguage() -> MockLanguage {
        return MockLanguage.createLanguage(language: .english, name: "english", id: getLanguageId(id: 0))
    }
    
    private func getSpanishLanguage() -> MockLanguage {
        return MockLanguage.createLanguage(language: .spanish, name: "spanish", id: getLanguageId(id: 1))
    }
    
    private func getVietnameseLanguage() -> MockLanguage {
        return MockLanguage.createLanguage(language: .vietnamese, name: "vietnamese", id: getLanguageId(id: 2))
    }
    
    private func getMockLanguage(language: LanguageCodeDomainModel) -> MockLanguage {
        switch language {
        case .english:
            return getEnglishLanguage()
        case .spanish:
            return getSpanishLanguage()
        case .vietnamese:
            return getVietnameseLanguage()
        default:
            assertionFailure("Mock language not supported: \(language)")
            return getEnglishLanguage()
        }
    }
}

// MARK: - RealmDatabase

extension ResourcesCacheTests {
    
    private func getRealmLanguage(language: LanguageCodeDomainModel) -> RealmLanguage {
        return RealmLanguage.createNewFrom(
            interface: getMockLanguage(language: language)
        )
    }
    
    private func getRealmLessons() -> [RealmResource] {
        
        let english = getRealmLanguage(language: .english)
        
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
        
        // featured
        let lesson_6 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 6), attrSpotlight: true))
        MockRealmResource.addLanguagesToResource(resource: lesson_6, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_7 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 7), attrSpotlight: true))
        MockRealmResource.addLanguagesToResource(resource: lesson_7, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_8 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 8), attrSpotlight: true))
        MockRealmResource.addLanguagesToResource(resource: lesson_8, addLanguages: [.english], fromLanguages: [english])
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5, lesson_6, lesson_7, lesson_8]
    }
    
    private func getRealmTracts() -> [RealmResource] {
        
        let english = getRealmLanguage(language: .english)
        
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
    private func getSwiftLanguage(language: LanguageCodeDomainModel) -> SwiftLanguage {
        return SwiftLanguage.createNewFrom(
            interface: getMockLanguage(language: language)
        )
    }
    
    @available(iOS 17.4, *)
    private func getLessons() -> [SwiftResource] {
        
        let english = getSwiftLanguage(language: .english)
        
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
        
        // featured
        let lesson_6 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 6), attrSpotlight: true))
        MockSwiftResource.addLanguagesToResource(resource: lesson_6, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_7 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 7), attrSpotlight: true))
        MockSwiftResource.addLanguagesToResource(resource: lesson_7, addLanguages: [.english], fromLanguages: [english])
        
        let lesson_8 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 8), attrSpotlight: true))
        MockSwiftResource.addLanguagesToResource(resource: lesson_8, addLanguages: [.english], fromLanguages: [english])
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5, lesson_6, lesson_7, lesson_8]
    }
    
    @available(iOS 17.4, *)
    private func getTracts() -> [SwiftResource] {
        
        let english = getSwiftLanguage(language: .english)
        
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
