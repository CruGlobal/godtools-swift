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
    
    func getLanguage(id: String) -> LanguageDataModel? {
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    func getLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        do {
            return try cache.getLanguageByCode(code: code)
        }
        catch _ {
            return nil
        }
    }
    
    func getLanguagesByCodes(codes: [BCP47LanguageIdentifier]) async throws -> [LanguageDataModel] {
        return try await cache.getLanguagesByCodes(codes: codes)
    }
    
    func getLanguagesPublisher(codes: [BCP47LanguageIdentifier]) -> AnyPublisher<[LanguageDataModel], Error> {
        
        return AnyPublisher() {
            try await self.cache.getLanguagesByCodes(codes: codes)
        }
    }
    
    func getLanguages() async throws -> [LanguageDataModel] {
        do {
            return try await cache.persistence.getDataModelsAsync(getOption: .allObjects)
        }
        catch _ {
            return Array()
        }
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageDataModel], Error> {
        return AnyPublisher() {
            return try await self.getLanguages()
        }
    }
    
    func getLanguagesByIds(ids: [String]) async throws -> [LanguageDataModel] {
        do {
            return try await cache.persistence.getDataModelsAsync(getOption: .objectsByIds(ids: ids))
        }
        catch _ {
            return Array()
        }
    }
    
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
