//
//  RealmAttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAttachmentsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getAttachment(id: String) -> AttachmentModel? {
        
        guard let realmAttachment = realmDatabase.openRealm().object(ofType: RealmAttachment.self, forPrimaryKey: id) else {
            return nil
        }
        
        return AttachmentModel(model: realmAttachment)
    }
}
