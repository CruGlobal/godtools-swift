//
//  RealmSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmSHA256FileCache {
    
    private let mainThreadRealm: Realm
    
    required init(realmDatabase: RealmDatabase) {
        
        self.mainThreadRealm = realmDatabase.mainThreadRealm
    }
    
    func getSHA256File(sha256: String) -> RealmSHA256File? {
        
        return mainThreadRealm.object(ofType: RealmSHA256File.self, forPrimaryKey: sha256)
    }
    
    func addSHA256Files(sha256Files: [RealmSHA256File]) -> Error? {
        
        do {
            try mainThreadRealm.write {
                mainThreadRealm.add(sha256Files, update: .all)
            }
            return nil
        }
        catch let error {
            return error
        }
    }
}
