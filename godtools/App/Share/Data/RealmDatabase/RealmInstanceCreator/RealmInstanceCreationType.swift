//
//  RealmInstanceCreationType.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

enum RealmInstanceCreationType {
    
    // Should always be the default.
    case alwaysCreatesANewRealmInstance
    
    // This is best used when using an in memory Realm (not using disk) because when using an in memory realm once the Realm instance goes out of scope, all data will be deleted.
    // A common scenario is when running tests there may be multiple realm instances for storing data and fetching data. So if tests are using an in memory realm, and the tests are
    // creating multiple realm instances, data would be lost.
    // See realm's documentation on in memory realm instances (https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/realm-files/configure-and-open-a-realm/#open-an-in-memory-realm)
    case usesASingleSharedRealmInstance
}
