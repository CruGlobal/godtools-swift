//
//  GTDataManager+Migrations.swift
//  godtools
//
//  Created by Ryan Carlson on 6/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

extension GTDataManager {
    static func config() -> Realm.Configuration  {
        return Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: DownloadedResource.className(), { (old, new) in
                        new!["aboutBannerRemoteId"] = ""
                    })
                }
                
                if oldSchemaVersion < 2 {
                    // removes Language.localizedName(), happens automatically, nothing to do here
                }
        })
    }
}
