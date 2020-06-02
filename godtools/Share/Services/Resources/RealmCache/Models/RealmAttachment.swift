//
//  RealmAttachment.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAttachment: Object, AttachmentType {
    
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var attributes: RealmAttachmentAttributes?
    @objc dynamic var resource: RealmResource?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
