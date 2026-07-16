//
//  SwiftResource+AddRelationships.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

@available(iOS 17.4, *)
extension SwiftResource {
    
    func addLanguages(
        addLanguages: [LanguageCodeDomainModel],
        fromLanguages: [SwiftLanguage]
    ) {

        for language in addLanguages {

            guard let swiftLanguage = fromLanguages.first(where: { $0.code == language.rawValue }) else {
                continue
            }

            addLanguage(language: swiftLanguage)
        }
    }
}
