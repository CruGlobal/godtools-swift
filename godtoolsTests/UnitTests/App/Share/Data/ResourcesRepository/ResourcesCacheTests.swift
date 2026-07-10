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

struct ResourcesCacheTests {

    private let englishLanguageId: Int = 0
    private let spanishLanguageId: Int = 1
    
    @Test()
    func getLessonCount() async throws {
        
        let expectedLessonCount: Int = 7
        
        let cache = try getCache()
        
        #expect(try cache.getLessonsCount(filterByLanguageId: nil) == expectedLessonCount)
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
              
        let cache = try getCache()
                
        let lessons: [ResourceDataModel] = try await cache.getLessons(filterByLanguageId: nil, sorted: false)
                
        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
    }
    
    @Test()
    func getLessonsByLanguageId() async throws {
        
        let expectedLessonIds: [String] = [
            getLessonId(id: 2),
            getLessonId(id: 6)
        ]
        
        let cache = try getCache()
        
        let lessons: [ResourceDataModel] = try await cache.getLessons(
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
                
        let cache = try getCache()
                
        let lessons: [ResourceDataModel] = try await cache.getFeaturedLessons(sorted: false)

        #expect(lessons.map {$0.id}.sorted() == expectedLessonIds)
    }
    
    @Test()
    func getLessonsSupportedLanguageIds() async throws {
        
        let expectedLanguageIds: [String] = [
            getLanguageId(id: englishLanguageId),
            getLanguageId(id: spanishLanguageId)
        ]
        
        let cache = try getCache()
        
        let realmLessonLanguageIds = try cache.getLessonsSupportedLanguageIds()
        
        #expect(realmLessonLanguageIds.sorted() == expectedLanguageIds.sorted())
    }
}

extension ResourcesCacheTests {
    
    private func getCache() throws -> ResourcesCache {
        
        let testsDiContainer = try TestsDiContainer(
            addRealmObjects: getRealmResources()
        )
        
        let realmDatabase: RealmDatabase = testsDiContainer.core.dataLayer.getSharedRealmDatabase()
        
        let persistence = RealmRepositorySyncPersistence(
            database: realmDatabase,
            mapping: RealmResourceMapping()
        )
        
        let trackDownloadedTranslationsRepository = TrackDownloadedTranslationsRepository(
            cache: TrackDownloadedTranslationsCache(
                persistence: RealmRepositorySyncPersistence(
                    database: realmDatabase,
                    mapping: RealmDownloadedTranslationMapping()
                )
            )
        )
        
        return ResourcesCache(
            persistence: persistence,
            realmDatabase: realmDatabase,
            realmDataWrite: RealmDataWrite(config: realmDatabase.databaseConfig.config),
            trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
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
    
    private func getLanguageCodable(language: LanguageCodeDomainModel, name: String, id: String) -> LanguageCodable {
        return LanguageCodable.random(
            id: id,
            code: language.rawValue,
            name: name,
            forceLanguageName: false
        )
    }

    private func getEnglishLanguage() -> LanguageCodable {
        return getLanguageCodable(language: .english, name: "english", id: getLanguageId(id: 0))
    }

    private func getSpanishLanguage() -> LanguageCodable {
        return getLanguageCodable(language: .spanish, name: "spanish", id: getLanguageId(id: spanishLanguageId))
    }

    private func getVietnameseLanguage() -> LanguageCodable {
        return getLanguageCodable(language: .vietnamese, name: "vietnamese", id: getLanguageId(id: 2))
    }

    private func getCzechLanguage() -> LanguageCodable {
        return getLanguageCodable(language: .czech, name: "czech", id: getLanguageId(id: 3))
    }

    private func getLanguage(language: LanguageCodeDomainModel) -> LanguageCodable {
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
            assertionFailure("Language not supported: \(language)")
            return getEnglishLanguage()
        }
    }
}

// MARK: - RealmDatabase

extension ResourcesCacheTests {
    
    private func getRealmLanguage(language: LanguageCodeDomainModel) -> RealmLanguage {
        return RealmLanguage.createNewFrom(
            model: getLanguage(language: language).toModel()
        )
    }
    
    private func getRealmLessons() -> [RealmResource] {
        
        let english = getRealmLanguage(language: .english)
        let spanish = getRealmLanguage(language: .spanish)
        
        let lesson_0 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 0)).toModel())
        lesson_0.addLanguage(language: english)
        
        let lesson_1 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 1)).toModel())
        lesson_1.addLanguage(language: english)
        
        let lesson_2 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 2)).toModel())
        lesson_2.addLanguage(language: english)
        lesson_2.addLanguage(language: spanish)
        
        let lesson_3 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 3)).toModel())
        lesson_3.addLanguage(language: english)
                
        // hidden
        let lesson_4 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 4), isHidden: true).toModel())
        lesson_4.addLanguage(language: english)
        lesson_4.addLanguage(language: spanish)
        
        let lesson_5 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 5), isHidden: true).toModel())
        lesson_5.addLanguage(language: english)
        
        // featured
        let lesson_6 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 6), attrSpotlight: true).toModel())
        lesson_6.addLanguage(language: english)
        lesson_6.addLanguage(language: spanish)
        
        let lesson_7 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 7), attrSpotlight: true).toModel())
        lesson_7.addLanguage(language: english)
        
        let lesson_8 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 8), attrSpotlight: true).toModel())
        lesson_8.addLanguage(language: english)
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5, lesson_6, lesson_7, lesson_8]
    }
    
    private func getRealmTracts() -> [RealmResource] {
        
        let english = getRealmLanguage(language: .english)
        let vietnamese = getRealmLanguage(language: .vietnamese)
        let czech = getRealmLanguage(language: .czech)
        let spanish = getRealmLanguage(language: .spanish)
        
        let tract_0 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 0)).toModel())
        tract_0.addLanguage(language: english)
        tract_0.addLanguage(language: czech)
        tract_0.addLanguage(language: vietnamese)
        tract_0.addLanguage(language: spanish)
        
        let tract_1 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 1)).toModel())
        tract_1.addLanguage(language: english)
        tract_1.addLanguage(language: vietnamese)
        
        let tract_2 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 2)).toModel())
        tract_2.addLanguage(language: english)
        tract_2.addLanguage(language: vietnamese)
        
        let tract_3 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 3)).toModel())
        tract_3.addLanguage(language: english)
        tract_3.addLanguage(language: czech)
        
        let tract_4 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 4)).toModel())
        tract_4.addLanguage(language: english)
        tract_4.addLanguage(language: czech)
        tract_4.addLanguage(language: spanish)
        
        let tract_5 = RealmResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 5)).toModel())
        tract_5.addLanguage(language: english)
        tract_5.addLanguage(language: spanish)
    
        return [tract_0, tract_1, tract_2, tract_3, tract_4, tract_5]
    }
    
    private func getRealmResources() -> [RealmResource] {
        
        return getRealmLessons() + getRealmTracts()
    }
}

// MARK: - SwiftDatabase

extension ResourcesCacheTests {
    
    @available(iOS 17.4, *)
    private func getSwiftLanguage(language: LanguageCodeDomainModel) -> SwiftLanguage {
        return SwiftLanguage.createNewFrom(
            model: getLanguage(language: language).toModel()
        )
    }
    
    @available(iOS 17.4, *)
    private func getLessons() -> [SwiftResource] {
        
        let english = getSwiftLanguage(language: .english)
        let spanish = getSwiftLanguage(language: .spanish)
        
        let lesson_0 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 0)).toModel())
        lesson_0.addLanguage(language: english)
        
        let lesson_1 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 1)).toModel())
        lesson_1.addLanguage(language: english)
        
        let lesson_2 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 2)).toModel())
        lesson_2.addLanguage(language: english)
        lesson_2.addLanguage(language: spanish)
        
        let lesson_3 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 3)).toModel())
        lesson_3.addLanguage(language: english)
                
        // hidden
        let lesson_4 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 4), isHidden: true).toModel())
        lesson_4.addLanguage(language: english)
        lesson_4.addLanguage(language: spanish)
        
        let lesson_5 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 5), isHidden: true).toModel())
        lesson_5.addLanguage(language: english)
        
        // featured
        let lesson_6 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 6), attrSpotlight: true).toModel())
        lesson_6.addLanguage(language: english)
        lesson_6.addLanguage(language: spanish)
        
        let lesson_7 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 7), attrSpotlight: true).toModel())
        lesson_7.addLanguage(language: english)
        
        let lesson_8 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .lesson, id: getLessonId(id: 8), attrSpotlight: true).toModel())
        lesson_8.addLanguage(language: english)
        
        return [lesson_0, lesson_1, lesson_2, lesson_3, lesson_4, lesson_5, lesson_6, lesson_7, lesson_8]
    }
    
    @available(iOS 17.4, *)
    private func getTracts() -> [SwiftResource] {
        
        let english = getSwiftLanguage(language: .english)
        let vietnamese = getSwiftLanguage(language: .vietnamese)
        let czech = getSwiftLanguage(language: .czech)
        let spanish = getSwiftLanguage(language: .spanish)
        
        let tract_0 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 0)).toModel())
        tract_0.addLanguage(language: english)
        tract_0.addLanguage(language: czech)
        tract_0.addLanguage(language: vietnamese)
        tract_0.addLanguage(language: spanish)
        
        let tract_1 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 1)).toModel())
        tract_1.addLanguage(language: english)
        tract_1.addLanguage(language: vietnamese)
        
        let tract_2 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 2)).toModel())
        tract_2.addLanguage(language: english)
        tract_2.addLanguage(language: vietnamese)
        
        let tract_3 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 3)).toModel())
        tract_3.addLanguage(language: english)
        tract_3.addLanguage(language: czech)
        
        let tract_4 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 4)).toModel())
        tract_4.addLanguage(language: english)
        tract_4.addLanguage(language: czech)
        tract_4.addLanguage(language: spanish)
        
        let tract_5 = SwiftResource.createNewFrom(model: FakeResource.createResource(resourceType: .tract, id: getTractId(id: 5)).toModel())
        tract_5.addLanguage(language: english)
        tract_5.addLanguage(language: spanish)
    
        return [tract_0, tract_1, tract_2, tract_3, tract_4, tract_5]
    }
    
    @available(iOS 17.4, *)
    private func getResources() -> [SwiftResource] {
        
        return getLessons() + getTracts()
    }
}

