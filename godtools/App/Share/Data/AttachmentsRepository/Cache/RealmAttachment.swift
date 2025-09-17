//
//  RealmAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAttachment: Object, IdentifiableRealmObject, AttachmentDataModelInterface {
    
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
    
    func mapFrom(interface: AttachmentDataModelInterface) {

        file = interface.file
        fileFilename = interface.fileFilename
        id = interface.id
        isZipped = interface.isZipped
        sha256 = interface.sha256
        type = interface.type
    }
    
    static func createNewFrom(interface: AttachmentDataModelInterface) -> RealmAttachment {
        
        let realmAttachment = RealmAttachment()
        realmAttachment.mapFrom(interface: interface)
        return realmAttachment
    }
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let realmResource = resource else {
            return nil
        }
        
        return ResourceDataModel(interface: realmResource)
    }
}
