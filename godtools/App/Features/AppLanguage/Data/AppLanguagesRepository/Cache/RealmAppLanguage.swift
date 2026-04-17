//
//  RealmAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 5/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmAppLanguage: Object, IdentifiableRealmObject {

    @Persisted var id: String = ""
    @Persisted var languageCode: String = ""
    @Persisted var realmLanguageDirection: RealmAppLanguageDirection = .leftToRight
    @Persisted var languageId: String = ""
    @Persisted var languageScriptCode: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: AppLanguageDataModel) {
        
        id = model.languageId
        languageCode = model.languageCode
        languageId = model.languageId
        languageScriptCode = model.languageScriptCode
        
        switch model.languageDirection {
        case .leftToRight:
            realmLanguageDirection = .leftToRight
        case .rightToLeft:
            realmLanguageDirection = .rightToLeft
        }
    }
    
    static func createNewFrom(model: AppLanguageDataModel) -> RealmAppLanguage {
        let object = RealmAppLanguage()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmAppLanguage {
    
    var languageDirection: AppLanguageDataModel.Direction {
    
        switch realmLanguageDirection {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}

extension RealmAppLanguage {
    
    func toModel() -> AppLanguageDataModel {
        
        return AppLanguageDataModel(
            languageCode: languageCode,
            languageDirection: languageDirection,
            languageScriptCode: languageScriptCode
        )
    }
}
