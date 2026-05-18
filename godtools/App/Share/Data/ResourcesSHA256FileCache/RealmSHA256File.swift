//
//  RealmSHA256File.swift
//  godtools
//
//  Created by Levi Eggert on 6/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmSHA256File: Object, SHA256FileModelType {
    
    @objc dynamic var sha256WithPathExtension: String = ""
    
    let attachments = List<RealmAttachment>()
    let translations = List<RealmTranslation>()
        
    override static func primaryKey() -> String? {
        return "sha256WithPathExtension"
    }
    
    func copy() -> RealmSHA256File {
        
        let object = RealmSHA256File()
        
        object.sha256WithPathExtension = sha256WithPathExtension
        object.attachments.append(objectsIn: attachments)
        object.translations.append(objectsIn: translations)
        
        return object
    }
}
