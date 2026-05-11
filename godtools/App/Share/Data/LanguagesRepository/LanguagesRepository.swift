//
//  LanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import RepositorySync
import Combine

final class LanguagesRepository {
    
    private let api: LanguagesApiInterface
    private let jsonFileCache: LanguagesJsonFileCache
    private let cache: LanguagesCache
    
    init(api: LanguagesApiInterface, jsonFileCache: LanguagesJsonFileCache, cache: LanguagesCache) {
        
        self.api = api
        self.jsonFileCache = jsonFileCache
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getLanguageNonThrowing(id: String) -> LanguageDataModel? {
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getLanguageNonThrowing(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        do {
            return try cache.getLanguageByCode(code: code)
        }
        catch _ {
            return nil
        }
    }
    
    func getLanguage(id: String) throws -> LanguageDataModel? {
        return try cache.persistence.getDataModel(id: id)
    }
    
    func getLanguage(code: BCP47LanguageIdentifier) throws -> LanguageDataModel? {
        return try cache.getLanguageByCode(code: code)
    }
    
    func getLanguagesByCodes(codes: [BCP47LanguageIdentifier]) async throws -> [LanguageDataModel] {
        return try await cache.getLanguagesByCodes(codes: codes)
    }
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func getLanguagesPublisher(codes: [BCP47LanguageIdentifier]) -> AnyPublisher<[LanguageDataModel], Error> {
        
        return AnyPublisher() {
            try await self.cache.getLanguagesByCodes(codes: codes)
        }
    }
    
    func getLanguages() async throws -> [LanguageDataModel] {
        return try await cache.persistence.getDataModelsAsync(getOption: .allObjects)
    }
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func getLanguagesPublisher() -> AnyPublisher<[LanguageDataModel], Error> {
        return AnyPublisher() {
            return try await self.getLanguages()
        }
    }
    
    func getLanguagesByIds(ids: [String]) async throws -> [LanguageDataModel] {
        return try await cache.persistence.getDataModelsAsync(getOption: .objectsByIds(ids: ids))
    }
    
    @available(*, deprecated) // Remove and use async throws. ~Levi
    func getLanguagesByIdsPublisher(ids: [String]) -> AnyPublisher<[LanguageDataModel], Error> {
        return AnyPublisher() {
            return try await self.getLanguagesByIds(ids: ids)
        }
    }
}

// MARK: - Sync

extension LanguagesRepository {
    
    func syncLanguagesFromRemote(requestPriority: RequestPriority) async throws -> [LanguageDataModel] {
        
        let languages: [LanguageCodable] = try await api.getLanguages(requestPriority: requestPriority)
        
        return try await cache.persistence.writeObjectsAsync(
            externalObjects: languages,
            writeOption: nil,
            getOption: .allObjects
        )
    }
    
    func syncLanguagesFromJsonFileCache() async throws -> [LanguageDataModel] {
        
        let languages: [LanguageCodable] = try jsonFileCache.getLanguages()
        
        return try await cache.persistence.writeObjectsAsync(
            externalObjects: languages,
            writeOption: nil,
            getOption: .allObjects
        )
    }
}
