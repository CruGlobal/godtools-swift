//
//  RealmAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmAttachment: Object, IdentifiableRealmObject {
    
    @objc dynamic var file: String = ""
    @objc dynamic var fileFilename: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var isZipped: Bool = false
    @objc dynamic var resourceId: String?
    @objc dynamic var sha256: String = ""
    @objc dynamic var type: String = ""
    
    @objc dynamic var resource: RealmResource?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: AttachmentDataModel) {

        file = model.file
        fileFilename = model.fileFilename
        id = model.id
        isZipped = model.isZipped
        sha256 = model.sha256
        type = model.type
    }
    
    static func createNewFrom(model: AttachmentDataModel) -> RealmAttachment {
        
        let realmAttachment = RealmAttachment()
        realmAttachment.mapFrom(model: model)
        return realmAttachment
    }
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let realmResource = resource else {
            return nil
        }
        
        return realmResource.toModel()
    }
}

extension RealmAttachment {
    
    func toModel() -> AttachmentDataModel {
        return AttachmentDataModel(
            id: id,
            file: file,
            fileFilename: fileFilename,
            isZipped: isZipped,
            sha256: sha256,
            type: type,
            resourceDataModel: resourceDataModel,
            storedAttachment: nil
        )
    }
}
