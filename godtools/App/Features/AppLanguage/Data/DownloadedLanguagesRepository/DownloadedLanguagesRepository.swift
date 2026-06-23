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
        
        return try await self.cache.persistence.getDataModels(getOption: .allObjects)
    }
    
    func storeDownloadedLanguage(languageId: String, downloadComplete: Bool) async throws -> DownloadedLanguageDataModel {
                
        let downloadedLanguage: DownloadedLanguageDataModel
        
        if let existing = try getDownloadedLanguage(languageId: languageId) {
            downloadedLanguage = existing.copy(downloadComplete: downloadComplete)
        }
        else {
            downloadedLanguage = DownloadedLanguageDataModel(languageId: languageId, downloadComplete: downloadComplete, createdAt: Date())
        }
        
        _ = try await cache.persistence.writeObjects(externalObjects: [downloadedLanguage])
        
        return downloadedLanguage
    }
    
    func storeDownloadedLanguage(downloadedLanguage: DownloadedLanguageDataModel) async throws -> DownloadedLanguageDataModel {
        
        _ = try await cache.persistence.writeObjects(externalObjects: [downloadedLanguage])
        
        return downloadedLanguage
    }
    
    func deleteDownloadedLanguage(languageId: String) async throws {
        
        try await cache.deleteDownloadedLanguage(languageId: languageId)
    }
    
    func markAllDownloadsAsCompleted() async throws {
        
        let incompleteDownloads: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(downloadComplete: false)
        
        guard incompleteDownloads.count > 0 else {
            return
        }
        
        let fiveMinutes: Double = 5 * 60
        
        var downloadsToUpdate: [DownloadedLanguageDataModel] = Array()
        
        for download in incompleteDownloads {
            
            let secondsSinceDownloadStarted: Double = Date().timeIntervalSince(download.createdAt)
            
            guard secondsSinceDownloadStarted >= fiveMinutes else {
                continue
            }
            
            downloadsToUpdate.append(
                download.copy(downloadComplete: true)
            )
        }
        
        try await cache.persistence.writeObjects(externalObjects: downloadsToUpdate)
    }
}
