//
//  TutorialSupportedLanguagesType.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialSupportedLanguagesType {
    
    var supportedLanguageCodes: [String] { get }
    
    func supportsLanguageCode(code: String) -> Bool
    func supportsLanguageCode(fromLanguageCodes: [String]) -> Bool
}
