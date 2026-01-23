//
//  RealmUserLocalizationSettingsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserLocalizationSettingsCache {

    private let realmDatabase: LegacyRealmDatabase

    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }

    func storeUserLocalizationSetting(dataModel: UserLocalizationSettingsDataModel) {

        let realm: Realm = realmDatabase.openRealm()

        let realmSetting = RealmUserLocalizationSettings()
        realmSetting.mapFrom(dataModel: dataModel)

        do {
            try realm.write {
                realm.add(realmSetting, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }

    func getUserLocalizationSetting() -> UserLocalizationSettingsDataModel? {

        let realm: Realm = realmDatabase.openRealm()

        guard let realmSetting = realm.object(ofType: RealmUserLocalizationSettings.self, forPrimaryKey: RealmUserLocalizationSettings.primaryKeyValue) else {
            return nil
        }

        return UserLocalizationSettingsDataModel(realmObject: realmSetting)
    }

    func getUserLocalizationSettingPublisher() -> AnyPublisher<UserLocalizationSettingsDataModel?, Never> {

        return Just(getUserLocalizationSetting())
            .eraseToAnyPublisher()
    }
}
