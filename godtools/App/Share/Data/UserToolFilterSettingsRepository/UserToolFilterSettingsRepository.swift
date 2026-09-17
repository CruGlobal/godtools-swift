//
//  UserToolFilterSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

final class UserToolFilterSettingsRepository: Sendable {
    
    // TODO: Replace with the authenticated user's id once settings are persisted per user. GT-3086
    static let sharedUserId: String = "shared"
    
    private let cache: UserToolFilterSettingsCache
    
    init(cache: UserToolFilterSettingsCache) {
        
        self.cache = cache
    }
}

// MARK: - Observe

extension UserToolFilterSettingsRepository {
    
    @MainActor func observeSettingValueChangedPublisher(settingType: UserToolFilterSettingType, userId: String = UserToolFilterSettingsRepository.sharedUserId) -> AnyPublisher<String?, Never> {
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
            }
            .map { _ in
                
                return Deferred {
                    Future<String?, Never> { promise in
                        Task {
                            promise(.success(await self.getSettingValue(settingType: settingType, userId: userId)))
                        }
                    }
                }
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

// MARK: - Read

extension UserToolFilterSettingsRepository {
    
    func getSetting(settingType: UserToolFilterSettingType, userId: String = UserToolFilterSettingsRepository.sharedUserId) async -> UserToolFilterSettingsDataModel? {
        
        let id: String = UserToolFilterSettingsDataModel.createId(userId: userId, settingType: settingType)
        
        do {
            return try await cache.persistence.getDataModels(getOption: .object(id: id)).first
        }
        catch _ {
            return nil
        }
    }
    
    func getSettingValue(settingType: UserToolFilterSettingType, userId: String = UserToolFilterSettingsRepository.sharedUserId) async -> String? {
        
        return await getSetting(settingType: settingType, userId: userId)?.value
    }
    
    func getSettings(userId: String = UserToolFilterSettingsRepository.sharedUserId) async -> [UserToolFilterSettingsDataModel] {
        
        let ids: Set<String> = Set(UserToolFilterSettingType.allCases.map {
            UserToolFilterSettingsDataModel.createId(userId: userId, settingType: $0)
        })
        
        do {
            return try await cache.persistence.getDataModels(getOption: .objectsByIds(ids: ids))
        }
        catch _ {
            return Array()
        }
    }
}

// MARK: - Write

extension UserToolFilterSettingsRepository {
    
    func storeSettingValue(settingType: UserToolFilterSettingType, value: String?, userId: String = UserToolFilterSettingsRepository.sharedUserId) async throws {
        
        guard await getSettingValue(settingType: settingType, userId: userId) != value else {
            return
        }
        
        guard let value = value else {
            try await deleteSetting(settingType: settingType, userId: userId)
            return
        }
        
        let dataModel = UserToolFilterSettingsDataModel(
            userId: userId,
            settingType: settingType,
            value: value,
            createdAt: Date()
        )
        
        _ = try await cache.persistence.writeObjects(
            externalObjects: [dataModel],
            writeOption: nil,
            getOption: nil
        )
    }
    
    func deleteSetting(settingType: UserToolFilterSettingType, userId: String = UserToolFilterSettingsRepository.sharedUserId) async throws {
        
        let id: String = UserToolFilterSettingsDataModel.createId(userId: userId, settingType: settingType)
        
        _ = try await cache.persistence.deleteObjectsByIds(ids: [id], getOption: nil)
    }
}
