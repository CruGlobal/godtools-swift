//
//  Language.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

typealias Languages = List<Language>

class Language: Object {
    @objc dynamic var code = ""
    @objc dynamic var remoteId = ""
    @objc dynamic var shouldDownload = false
    @objc dynamic var direction = ""
    
    let translations = List<Translation>()
    
    override static func primaryKey() -> String {
        return "remoteId"
    }
    
    func isPrimary() -> Bool {
        return remoteId == GTSettings.shared.primaryLanguageId
    }
    
    func isParallel() -> Bool {
        return remoteId == GTSettings.shared.parallelLanguageId
    }
    
    func localizedName() -> String {
        guard let nameInLocale = NSLocale.current.localizedString(forIdentifier: self.code) else {
            return self.code
        }
        
        return nameInLocale
    }
    
    func isRightToLeft() -> Bool {
        return direction == "rtl"
    }
}
