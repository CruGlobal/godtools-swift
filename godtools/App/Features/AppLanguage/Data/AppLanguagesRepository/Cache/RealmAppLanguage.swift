//
//  RealmAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 5/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAppLanguage: Object {

    @Persisted var id: String = ""
    @Persisted var languageCode: String = ""
    @Persisted var realmLanguageDirection: RealmAppLanguageDirection = .leftToRight
    @Persisted var languageId: String = ""
    @Persisted var languageScriptCode: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(dataModel: AppLanguageDataModelInterface) {
        
        id = dataModel.languageId
        languageCode = dataModel.languageCode
        languageId = dataModel.languageId
        languageScriptCode = dataModel.languageScriptCode
        
        switch dataModel.languageDirection {
        case .leftToRight:
            realmLanguageDirection = .leftToRight
        case .rightToLeft:
            realmLanguageDirection = .rightToLeft
        }
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
