//
//  RealmDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 1/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

extension RealmDatabase {
    
    @available(*, deprecated)
    func openRealmNonThrowing() -> Realm? {
        do {
            return try openRealm()
        }
        catch let error {
            assertionFailure("Failed to open realm: \(error.localizedDescription)")
            return nil
        }
    }
}
