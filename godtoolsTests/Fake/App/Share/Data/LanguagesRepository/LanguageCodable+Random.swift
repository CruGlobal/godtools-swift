//
//  LanguageCodable+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension LanguageCodable {
    
    static func random(
        id: String = UUID().uuidString,
        code: String = LanguageCodeDomainModel.english.rawValue,
        directionString: String = String.random(),
        name: String = String.random(),
        type: String = String.random(),
        forceLanguageName: Bool = Bool.random()
    ) -> LanguageCodable {
        
        return LanguageCodable(
            id: id,
            code: code,
            directionString: directionString,
            name: name,
            type: type,
            forceLanguageName: forceLanguageName
        )
    }
}
