//
//  LanguagePreferencesType.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguagePreferencesType {
    
    var languageCode: String? { get }
    var isEnglish: Bool { get }
}
