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
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        
        return cache.persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
    
    func getDownloadedLanguage(languageId: String) throws -> DownloadedLanguageDataModel? {
        
        return try cache.persistence.getDataModel(id: languageId)
    }
    
    func getDownloadedLanguagesByDownloadComplete(downloadComplete: Bool) async throws -> [DownloadedLanguageDataModel] {
        
        return try await cache.getDownloadedLanguagesByDownloadComplete(downloadComplete: downloadComplete)
    }
    
    func getDownloadedLanguages() async throws -> [DownloadedLanguageDataModel] {
        
        return try await self.cache.persistence.getDataModelsAsync(getOption: .allObjects)
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
    
    func deleteDownloadedLanguage(languageId: String) throws {
        
        try cache.deleteDownloadedLanguage(languageId: languageId)
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
