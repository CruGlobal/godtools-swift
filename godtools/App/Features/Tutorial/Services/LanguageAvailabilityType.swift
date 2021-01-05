//
//  LanguageAvailabilityType.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageAvailabilityType {
        
    func isAvailableInLanguage(locale: Locale) -> Bool
    func isAvailableInLanguages(identifiers: [String]) -> Bool
}
