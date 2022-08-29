//
//  LanguageSupportable.swift
//  godtools
//
//  Created by Rachael Skeath on 8/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol LanguageSupportable {
    
    func supportsLanguage(languageId: String) -> Bool
}
