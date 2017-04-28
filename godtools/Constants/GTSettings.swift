//
//  GTSettings.swift
//  godtools
//
//  Created by Ryan Carlson on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

import Foundation

class GTSettings {
    static let shared = GTSettings()
    
    private var primaryLanguageIdInternal: String?
    private var parallelLanguageIdInternal: String?
    
    var primaryLanguageId: String? {
        get {
            if primaryLanguageIdInternal != nil {
                return primaryLanguageIdInternal
            }
            
            primaryLanguageIdInternal = UserDefaults.standard.string(forKey: "kPrimaryLanguageId")
            return primaryLanguageIdInternal
        }
        
        set {
            primaryLanguageIdInternal = primaryLanguageId
            UserDefaults.standard.set(primaryLanguageId, forKey: "kPrimaryLanguageId")
        }
    }
    
    var parallelLanguageId: String? {
        get {
            if parallelLanguageIdInternal != nil {
                return parallelLanguageIdInternal
            }
            
            parallelLanguageIdInternal = UserDefaults.standard.string(forKey: "kParallelLanguageId")
            return parallelLanguageIdInternal
        }
        
        set {
            primaryLanguageIdInternal = primaryLanguageId
            UserDefaults.standard.set(primaryLanguageId, forKey: "kParallelLanguageId")
        }
    }
}
