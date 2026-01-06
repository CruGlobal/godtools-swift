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
import RepositorySync

/*

struct ResourcesCacheTests {

    private let englishLanguageId: Int = 0
    private let spanishLanguageId: Int = 1
    
    @Test()
    func getLessonCount() async throws {
        
        let expectedLessonCount: Int = 7
        
        let realmResourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: false)
        
        #expect(realmResourcesCache.getLessonsCount() == expectedLessonCount)
        
        let resourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: true)
        
        #expect(resourcesCache.getLessonsCount() == expectedLessonCount)
    }
    
    @Test()
    func getLessons() async throws {
        
        let expectedLessonIds: [String] = [
            getLessonId(id: 0),
            getLessonId(id: 1),
            getLessonId(id: 2),
            getLessonId(id: 3),
            getLessonId(id: 6),
            getLessonId(id: 7),
            getLessonId(id: 8)
        ]
                
        let realmResourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: false)
        let realmLessons = realmResourcesCache.getLessons(filterByLanguageId: nil, sorted: false)
        
        #expect(realmLessons.map {$0.id}.sorted() == expectedLessonIds)
        
        let resourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: true)
        let lessons = resourcesCache.getLessons(filterByLanguageId: nil, sorted: false)
        
        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
    }
    
    @Test()
    func getLessonsByLanguageId() async throws {
        
        let expectedLessonIds: [String] = [
            getLessonId(id: 2),
            getLessonId(id: 6)
        ]
        
        let realmResourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: false)
        let realmLessons = realmResourcesCache.getLessons(
            filterByLanguageId: getLanguageId(id: spanishLanguageId),
            sorted: false
        )
        
        #expect(realmLessons.map {$0.id}.sorted() == expectedLessonIds)
        
        let resourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: true)
        let lessons = resourcesCache.getLessons(
            filterByLanguageId: getLanguageId(id: spanishLanguageId),
            sorted: false
        )
        
        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
    }
    
    @Test()
    func getFeaturedLessons() async throws {
        
        let expectedLessonIds: [String] = [
            getLessonId(id: 6),
            getLessonId(id: 7),
            getLessonId(id: 8)
        ]
                
        let realmResourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: false)
        let realmLessons = realmResourcesCache.getFeaturedLessons(sorted: false)
        
        #expect(realmLessons.map {$0.id}.sorted() == expectedLessonIds)
        
        let resourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: true)
        let lessons = resourcesCache.getFeaturedLessons(sorted: false)
        
        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
    }
    
    @Test()
    func getLessonsSupportedLanguageIds() async throws {
        
        let expectedLanguageIds: [String] = [
            getLanguageId(id: englishLanguageId),
            getLanguageId(id: spanishLanguageId)
        ]
        
        let realmResourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: false)
        let realmLessonLanguageIds = realmResourcesCache.getLessonsSupportedLanguageIds()
        
        #expect(realmLessonLanguageIds.sorted() == expectedLanguageIds.sorted())
        
        let resourcesCache = try getResourcesCache(swiftPersistenceIsEnabled: true)
        let lessonLanguageIds = resourcesCache.getLessonsSupportedLanguageIds()
        
        #expect(lessonLanguageIds.sorted() == expectedLanguageIds.sorted())
    }
}

extension ResourcesCacheTests {
    
    private func getResourcesCache(swiftPersistenceIsEnabled: Bool) throws -> ResourcesCache {
        
        if #available(iOS 17.4, *), swiftPersistenceIsEnabled {
            TempSharedSwiftDatabase.shared.setDatabase(
                swiftDatabase: try getSwiftDatabase()
            )
        }
        
        let realmDatabase: LegacyRealmDatabase = getLegacyRealmDatabase()
        
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
        return MockLanguage.createLanguage(language: .spanish, name: "spanish", id: getLanguageId(id: spanishLanguageId))
    }
    
    private func getVietnameseLanguage() -> MockLanguage {
        return MockLanguage.createLanguage(language: .vietnamese, name: "vietnamese", id: getLanguageId(id: 2))
    }
    
    private func getCzechLanguage() -> MockLanguage {
        return MockLanguage.createLanguage(language: .czech, name: "czech", id: getLanguageId(id: 3))
    }
    
    private func getMockLanguage(language: LanguageCodeDomainModel) -> MockLanguage {
        switch language {
        case .english:
            return getEnglishLanguage()
        case .spanish:
            return getSpanishLanguage()
        case .vietnamese:
            return getVietnameseLanguage()
        case .czech:
            return getCzechLanguage()
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
        let spanish = getRealmLanguage(language: .spanish)
        
        let lesson_0 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 0)))
        lesson_0.addLanguage(language: english)
        
        let lesson_1 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 1)))
        lesson_1.addLanguage(language: english)
        
        let lesson_2 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 2)))
        lesson_2.addLanguage(language: english)
        lesson_2.addLanguage(language: spanish)
        
        let lesson_3 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 3)))
        lesson_3.addLanguage(language: english)
                
        // hidden
        let lesson_4 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 4), isHidden: true))
        lesson_4.addLanguage(language: english)
        lesson_4.addLanguage(language: spanish)
        
        let lesson_5 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 5), isHidden: true))
        lesson_5.addLanguage(language: english)
        
        // featured
        let lesson_6 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 6), attrSpotlight: true))
        lesson_6.addLanguage(language: english)
        lesson_6.addLanguage(language: spanish)
        
        let lesson_7 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 7), attrSpotlight: true))
        lesson_7.addLanguage(language: english)
        
        let lesson_8 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 8), attrSpotlight: true))
        lesson_8.addLanguage(language: english)
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5, lesson_6, lesson_7, lesson_8]
    }
    
    private func getRealmTracts() -> [RealmResource] {
        
        let english = getRealmLanguage(language: .english)
        let vietnamese = getRealmLanguage(language: .vietnamese)
        let czech = getRealmLanguage(language: .czech)
        let spanish = getRealmLanguage(language: .spanish)
        
        let tract_0 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 0)))
        tract_0.addLanguage(language: english)
        tract_0.addLanguage(language: czech)
        tract_0.addLanguage(language: vietnamese)
        tract_0.addLanguage(language: spanish)
        
        let tract_1 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 1)))
        tract_1.addLanguage(language: english)
        tract_1.addLanguage(language: vietnamese)
        
        let tract_2 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 2)))
        tract_2.addLanguage(language: english)
        tract_2.addLanguage(language: vietnamese)
        
        let tract_3 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 3)))
        tract_3.addLanguage(language: english)
        tract_3.addLanguage(language: czech)
        
        let tract_4 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 4)))
        tract_4.addLanguage(language: english)
        tract_4.addLanguage(language: czech)
        tract_4.addLanguage(language: spanish)
        
        let tract_5 = RealmResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 5)))
        tract_5.addLanguage(language: english)
        tract_5.addLanguage(language: spanish)
    
        return [tract_0, tract_1, tract_2, tract_3, tract_4, tract_5]
    }
    
    private func getRealmResources() -> [RealmResource] {
        
        return getRealmLessons() + getRealmTracts()
    }
    
    private func getRealmDatabaseObjects() -> [Object] {
        return getRealmResources()
    }
    
    private func getLegacyRealmDatabase() -> LegacyRealmDatabase {
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
        let spanish = getSwiftLanguage(language: .spanish)
        
        let lesson_0 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 0)))
        lesson_0.addLanguage(language: english)
        
        let lesson_1 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 1)))
        lesson_1.addLanguage(language: english)
        
        let lesson_2 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 2)))
        lesson_2.addLanguage(language: english)
        lesson_2.addLanguage(language: spanish)
        
        let lesson_3 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 3)))
        lesson_3.addLanguage(language: english)
                
        // hidden
        let lesson_4 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 4), isHidden: true))
        lesson_4.addLanguage(language: english)
        lesson_4.addLanguage(language: spanish)
        
        let lesson_5 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 5), isHidden: true))
        lesson_5.addLanguage(language: english)
        
        // featured
        let lesson_6 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 6), attrSpotlight: true))
        lesson_6.addLanguage(language: english)
        lesson_6.addLanguage(language: spanish)
        
        let lesson_7 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 7), attrSpotlight: true))
        lesson_7.addLanguage(language: english)
        
        let lesson_8 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .lesson, id: getLessonId(id: 8), attrSpotlight: true))
        lesson_8.addLanguage(language: english)
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5, lesson_6, lesson_7, lesson_8]
    }
    
    @available(iOS 17.4, *)
    private func getTracts() -> [SwiftResource] {
        
        let english = getSwiftLanguage(language: .english)
        let vietnamese = getSwiftLanguage(language: .vietnamese)
        let czech = getSwiftLanguage(language: .czech)
        let spanish = getSwiftLanguage(language: .spanish)
        
        let tract_0 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 0)))
        tract_0.addLanguage(language: english)
        tract_0.addLanguage(language: czech)
        tract_0.addLanguage(language: vietnamese)
        tract_0.addLanguage(language: spanish)
        
        let tract_1 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 1)))
        tract_1.addLanguage(language: english)
        tract_1.addLanguage(language: vietnamese)
        
        let tract_2 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 2)))
        tract_2.addLanguage(language: english)
        tract_2.addLanguage(language: vietnamese)
        
        let tract_3 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 3)))
        tract_3.addLanguage(language: english)
        tract_3.addLanguage(language: czech)
        
        let tract_4 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 4)))
        tract_4.addLanguage(language: english)
        tract_4.addLanguage(language: czech)
        tract_4.addLanguage(language: spanish)
        
        let tract_5 = SwiftResource.createNewFrom(interface: MockResource.createResource(resourceType: .tract, id: getTractId(id: 5)))
        tract_5.addLanguage(language: english)
        tract_5.addLanguage(language: spanish)
    
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
    private func getSwiftDatabase() throws -> SwiftDatabase {
        return try TestsInMemorySwiftDatabase().createDatabase(addObjectsToDatabase: getSwiftDatabaseObjects())
    }
}


*/
