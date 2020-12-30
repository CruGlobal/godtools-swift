//
//  Language.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class Language: Object {
    @objc dynamic var code = ""
    @objc dynamic var remoteId = ""
    @objc dynamic var shouldDownload = false
    @objc dynamic var direction = ""
    @objc dynamic var name: String?
//    @objc dynamic var isPublished = true
    
    let translations = List<Translation>()
    let languageNamePrefix = "language_name_"
    
    var key: String {
        return languageNamePrefix + code
    }
    
    override static func primaryKey() -> String {
        return "remoteId"
    }
    
    func localizedName(locale: Locale = NSLocale.current, table: String? = nil) -> String {
        
        
        // Load localized string using language code as key
        let nameInLocalization = Bundle.main.localizedString(forKey: key, value: nil, table: table)
        // localizedString returns key if localized string not found. If returned string == code, then localized string not was not found
        if nameInLocalization != key {
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
