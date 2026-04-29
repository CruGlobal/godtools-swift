//
//  DownloadedLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class DownloadedLanguagesRepository {
    
    private let cache: DownloadedLanguagesCache
    
    init(cache: DownloadedLanguagesCache) {
        
        self.cache = cache
    }
    
    @MainActor func getDownloadedLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return cache.persistence
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getDownloadedLanguage(languageId: String) -> DownloadedLanguageDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: languageId)
        }
        catch let error {
            return nil
        }
    }
    
    func getDownloadedLanguagesByDownloadCompletePublisher(downloadComplete: Bool) -> AnyPublisher<[DownloadedLanguageDataModel], Error> {
        
        return AnyPublisher() {
            try await self.cache.getDownloadedLanguagesByDownloadComplete(downloadComplete: downloadComplete)
        }
    }
    
    func getDownloadedLanguagesPublisher() -> AnyPublisher<[DownloadedLanguageDataModel], Error> {
        return AnyPublisher() {
            try await self.cache.persistence.getDataModelsAsync(getOption: .allObjects)
        }
    }
    
    func storeDownloadedLanguage(languageId: String, downloadComplete: Bool) async throws -> DownloadedLanguageDataModel {
        
        let downloadedLanguage = DownloadedLanguageDataModel(
            id: languageId,
            createdAt: Date(),
            languageId: languageId,
            downloadComplete: downloadComplete
        )
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [downloadedLanguage],
            writeOption: nil,
            getOption: nil
        )
        
        return downloadedLanguage
    }
    
    func storeDownloadedLanguagePublisher(languageId: String, downloadComplete: Bool) -> AnyPublisher<DownloadedLanguageDataModel, Error> {
        
        return AnyPublisher() {
            try await self.storeDownloadedLanguage(languageId: languageId, downloadComplete: downloadComplete)
        }
    }
    
    func deleteDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<Void, Error> {
        
        return AnyPublisher() {
            try self.cache.deleteDownloadedLanguage(languageId: languageId)
        }
    }
    
    func markAllDownloadsAsCompleted() async throws {
        
        let incompleteDownloads: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(downloadComplete: false)
        
        let incompleteToCompletedDownloads = incompleteDownloads.map {
            $0.copy(downloadComplete: true)
        }
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: incompleteToCompletedDownloads,
            writeOption: nil,
            getOption: nil
        )
    }
}
