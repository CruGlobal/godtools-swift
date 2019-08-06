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
    @objc dynamic var name: String?
//    @objc dynamic var isPublished = true
    
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
    
    func localizedName(locale: Locale = NSLocale.current, table: String? = nil) -> String {
        
        // Load localized string using language code as key
        let nameInLocalization = Bundle.main.localizedString(forKey: code, value: nil, table: table)
        // localizedString returns key if localized string not found. If returned string == code, then localized string not was not found
        if nameInLocalization != code {
            return nameInLocalization
        }
        
        // Return device default localized language name, if found
        if let localizedName = locale.localizedString(forIdentifier: self.code) {
            return localizedName
        }
        
        // Return default name supplied by API, if not nil
        if let name = name {
            return name
        }
        
        // If no localization found, return the language code
        return code
    }
    
    func isRightToLeft() -> Bool {
        return direction == "rtl"
    }
}
