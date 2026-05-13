//
//  AppLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

typealias AppLanguageDomainModel = BCP47LanguageIdentifier // App language is a BCP-47 language id string

extension AppLanguageDomainModel {
    static var english: AppLanguageDomainModel {
        return LanguageCodeDomainModel.english.rawValue
    }
}
