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
    dynamic var code = ""
    dynamic var remoteId = ""
    dynamic var shouldDownload = false
    let translations = List<Translation>()
    
    func localizedName() -> String {
        guard let localizedName = NSLocale.current.localizedString(forLanguageCode: self.code) else {
            return self.code
        }
        
        return localizedName
    }
    
    func isPrimary() -> Bool {
        return remoteId == GTSettings.shared.primaryLanguageId
    }
    
    func isParallel() -> Bool {
        return remoteId == GTSettings.shared.parallelLanguageId
    }
}
