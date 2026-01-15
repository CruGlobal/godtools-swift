//
//  RealmUserLocalizationSettingCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserLocalizationSettingCache {

    private let realmDatabase: LegacyRealmDatabase

    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }

    func storeUserLocalizationSetting(dataModel: UserLocalizationSettingDataModel) {

        let realm: Realm = realmDatabase.openRealm()

        let realmSetting = RealmUserLocalizationSetting()
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

    func getUserLocalizationSetting() -> UserLocalizationSettingDataModel? {

        let realm: Realm = realmDatabase.openRealm()

        guard let realmSetting = realm.object(ofType: RealmUserLocalizationSetting.self, forPrimaryKey: RealmUserLocalizationSetting.primaryKeyValue) else {
            return nil
        }

        return UserLocalizationSettingDataModel(realmObject: realmSetting)
    }

    func getUserLocalizationSettingPublisher() -> AnyPublisher<UserLocalizationSettingDataModel?, Never> {

        return Just(getUserLocalizationSetting())
            .eraseToAnyPublisher()
    }
}
