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
    
    func mapFrom(interface: AppLanguageDataModelInterface) {
        
        id = interface.languageId
        languageCode = interface.languageCode
        languageId = interface.languageId
        languageScriptCode = interface.languageScriptCode
        
        switch interface.languageDirection {
        case .leftToRight:
            realmLanguageDirection = .leftToRight
        case .rightToLeft:
            realmLanguageDirection = .rightToLeft
        }
    }
    
    static func createNewFrom(interface: AppLanguageDataModelInterface) -> RealmAppLanguage {
        let object = RealmAppLanguage()
        object.mapFrom(interface: interface)
        return object
    }
}

extension RealmAppLanguage: AppLanguageDataModelInterface {
    
    var languageDirection: AppLanguageDataModel.Direction {
    
        switch realmLanguageDirection {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}
