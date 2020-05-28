//
//  LanguageRelationshipsType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageRelationshipsType: Codable {
        
    associatedtype LanguageTranslations: LanguageTranslationsType
    
    var languageTranslations: LanguageTranslations? { get }
}
