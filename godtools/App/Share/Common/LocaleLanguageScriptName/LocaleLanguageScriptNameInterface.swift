//
//  LocaleLanguageScriptNameInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol LocaleLanguageScriptNameInterface {
    
    func getScriptName(forScriptCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String?
}
