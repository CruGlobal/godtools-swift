//
//  UserLocalizationSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift
import Combine

class UserLocalizationSettingsCache {
        
    private let persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel>
    
    init(persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, SwiftUserLocalizationSettings>? {
        return persistence as? SwiftRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, SwiftUserLocalizationSettings>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, RealmUserLocalizationSettings>? {
        return persistence as? RealmRepositorySyncPersistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel, RealmUserLocalizationSettings>
    }
}

extension UserLocalizationSettingsCache {

    func storeUserLocalizationSetting(dataModel: UserLocalizationSettingsDataModel) -> AnyPublisher<Void, Error> {

        return persistence
            .writeObjectsPublisher(
                externalObjects: [dataModel],
                writeOption: nil,
                getOption: nil
            )
            .map { _ in
                return Void()
            }
            .eraseToAnyPublisher()
    }

    func getUserLocalizationSetting(id: String) -> UserLocalizationSettingsDataModel? {

        return persistence.getDataModelNonThrowing(id: id)
    }

    func getUserLocalizationSettingPublisher(id: String) -> AnyPublisher<UserLocalizationSettingsDataModel?, Error> {

        return persistence
            .getDataModelsPublisher(
                getOption: .object(id: id)
            )
            .map {
                return $0.first
            }
            .eraseToAnyPublisher()
    }
}
