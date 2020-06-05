//
//  RealmAttachmentAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAttachmentAttributes: Object, AttachmentAttributesType {
    
    @objc dynamic var file: String?
    @objc dynamic var isZipped: Bool = false
    @objc dynamic var sha256: String?
    @objc dynamic var fileFilename: String?
    
    enum CodingKeys: String, CodingKey {
        case file = "file"
        case isZipped = "is-zipped"
        case sha256 = "sha256"
        case fileFilename = "file-file-name"
    }
}
