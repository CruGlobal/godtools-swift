//
//  LanguageTranslationsType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguageTranslationsType: Codable {
        
    associatedtype TranslationsList: Sequence
    
    var data: TranslationsList { get }
}
