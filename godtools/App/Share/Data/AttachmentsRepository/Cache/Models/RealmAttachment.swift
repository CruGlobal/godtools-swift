//
//  RealmAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAttachment: Object, AttachmentModelType {
    
    @objc dynamic var file: String = ""
    @objc dynamic var fileFilename: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var isZipped: Bool = false
    @objc dynamic var sha256: String = ""
    @objc dynamic var type: String = ""
    
    @objc dynamic var resource: RealmResource?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: AttachmentModel, shouldIgnoreMappingPrimaryKey: Bool) {
        
        if !shouldIgnoreMappingPrimaryKey {
            id = model.id
        }
        
        file = model.file
        fileFilename = model.fileFilename
        isZipped = model.isZipped
        sha256 = model.sha256
        type = model.type
        
        if let modelResouce = model.resource {
            resource = RealmResource()
            resource?.mapFrom(model: modelResouce)
        }
        else {
            resource = nil
        }
    }
}
