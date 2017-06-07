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
    dynamic var code = "" {
        didSet {
            guard let nameInLocale = NSLocale.current.localizedString(forIdentifier: self.code) else {
                self.localizedName = self.code
                return
            }
            
            self.localizedName = nameInLocale
        }
    }
    dynamic var remoteId = ""
    dynamic var shouldDownload = false
    dynamic var localizedName = ""
    
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
}
