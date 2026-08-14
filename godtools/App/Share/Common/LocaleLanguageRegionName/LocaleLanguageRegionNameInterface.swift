//
//  LocaleLanguageRegionNameInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol LocaleLanguageRegionNameInterface: Sendable {
    
    func getRegionName(forRegionCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String?
}
