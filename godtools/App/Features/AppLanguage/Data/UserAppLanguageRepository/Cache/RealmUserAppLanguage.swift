//
//  RealmUserAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserAppLanguage: Object, IdentifiableRealmObject, UserAppLanguageDataModelInterface {
    
    @objc dynamic var id: String = ""
    @objc dynamic var languageId: BCP47LanguageIdentifier = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(interface: UserAppLanguageDataModelInterface) {
        id = interface.id
        languageId = interface.languageId
    }
    
    static func createNewFrom(interface: UserAppLanguageDataModelInterface) -> RealmUserAppLanguage {
        let object = RealmUserAppLanguage()
        object.mapFrom(interface: interface)
        return object
    }
}
