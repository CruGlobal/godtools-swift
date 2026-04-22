//
//  RealmSHA256File.swift
//  godtools
//
//  Created by Levi Eggert on 6/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmSHA256File: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var sha256WithPathExtension: String = ""
    
    let attachments = List<RealmAttachment>()
    let translations = List<RealmTranslation>()
        
    override static func primaryKey() -> String? {
        return "sha256WithPathExtension"
    }
}

extension RealmSHA256File {
    
    func mapFrom(model: SHA256FileModel) {
        
        id = model.id
        sha256WithPathExtension = model.sha256WithPathExtension
        
        attachments.removeAll()
        attachments.append(
            objectsIn: model.attachments.map {
                RealmAttachment.createNewFrom(model: $0)
            }
        )
        
        translations.removeAll()
        translations.append(
            objectsIn: model.translations.map {
                RealmTranslation.createNewFrom(model: $0)
            }
        )
    }
    
    static func createNewFrom(model: SHA256FileModel) -> RealmSHA256File {
        let object = RealmSHA256File()
        object.mapFrom(model: model)
        return object
    }
   
    func toModel() -> SHA256FileModel {
        return SHA256FileModel(
            id: id,
            sha256WithPathExtension: sha256WithPathExtension,
            attachments: attachments.map { $0.toModel() },
            translations: translations.map { $0.toModel() }
        )
    }
}
