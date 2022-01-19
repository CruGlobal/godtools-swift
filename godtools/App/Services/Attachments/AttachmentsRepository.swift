//
//  AttachmentsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AttachmentsRepository {
    
    private let cache: RealmAttachmentsCache
    
    required init(cache: RealmAttachmentsCache) {
        
        self.cache = cache
    }
    
    func getAttachment(fileFilename: String) -> AttachmentModel? {
        
        guard let realmAttachment = cache.getAttachment(fileFilename: fileFilename) else {
            return nil
        }
        
        return AttachmentModel(realmAttachment: realmAttachment)
    }
}
