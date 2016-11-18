//
//  GodToolsSettings.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation

class GodToolsSettings: NSObject {
    static let sharedSettings = GodToolsSettings()
    
    func primaryLanguage () -> String? {
        return UserDefaults.standard.value(forKey: "primaryLanguageCode") as? String
    }
    
    func setPrimaryLanguage (code: String) {
        UserDefaults.standard.set(code, forKey:"primaryLanguageCode")
    }
    
    func parallelLanguage() -> String? {
        return UserDefaults.standard.value(forKey: "parallelLanguageCode") as? String
    }
    
    func setParallelLanguage (code: String) {
        UserDefaults.standard.set(code, forKey:"parallelLanguageCode")
    }
}
