//
//  RealmAttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAttachmentsCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getAttachment(fileFilename: String) -> RealmAttachment? {
        
        let realm: Realm = realmDatabase.mainThreadRealm
        
        return realm.objects(RealmAttachment.self).filter("fileFilename = '\(fileFilename)'").first
    }
}
