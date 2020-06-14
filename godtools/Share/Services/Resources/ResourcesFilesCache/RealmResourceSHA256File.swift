//
//  RealmResourceSHA256File.swift
//  godtools
//
//  Created by Levi Eggert on 6/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResourceSHA256File: Object {
    
    @objc dynamic var sha256: String = ""
    @objc dynamic var pathExtension: String = ""
    
    let attachments = List<RealmAttachment>()
    let translations = List<RealmTranslation>()
        
    override static func primaryKey() -> String? {
        return "sha256"
    }
}
