//
//  MockLocaleLanguageScriptName.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockLocaleLanguageScriptName: LocaleLanguageScriptNameInterface {
    
    typealias ScriptCode = String
    typealias TranslateInLocaleId = String
    typealias ScriptName = String
    
    private let scriptNames: [ScriptCode: [TranslateInLocaleId: ScriptName]]
    
    init(scriptNames: [ScriptCode: [TranslateInLocaleId: ScriptName]]) {
        
        self.scriptNames = scriptNames
    }
    
    func getScriptName(forScriptCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        if let translatedInLanguageId = translatedInLanguageId {
            
            return scriptNames[forScriptCode]?[translatedInLanguageId]
        }
        
        return scriptNames[forScriptCode]?[forScriptCode]
    }
}
