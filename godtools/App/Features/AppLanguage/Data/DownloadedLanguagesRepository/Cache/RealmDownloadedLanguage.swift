//
//  RealmDownloadedLanguage.swift
//  godtools
//
//  Created by Rachael Skeath on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmDownloadedLanguage: Object, IdentifiableRealmObject {
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var languageId: String = ""
    @objc dynamic var downloadComplete: Bool = false
    
    @objc dynamic var id: String {
        get {
            return languageId
        }
        set {
            languageId = newValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "languageId"
    }
}

extension RealmDownloadedLanguage {
    
    func mapFrom(model: DownloadedLanguageDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        languageId = model.languageId
        downloadComplete = model.downloadComplete
    }
    
    static func createNewFrom(model: DownloadedLanguageDataModel) -> RealmDownloadedLanguage {
        
        let object = RealmDownloadedLanguage()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> DownloadedLanguageDataModel {
        return DownloadedLanguageDataModel(
            id: id,
            createdAt: createdAt,
            languageId: languageId,
            downloadComplete: downloadComplete
        )
    }
}
