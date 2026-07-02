//
//  LanguageCodable+ToModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension LanguageCodable {
    
    func toModel() -> LanguageDataModel {
        return LanguageDataModel(
            code: code,
            directionString: directionString,
            id: id,
            name: name,
            type: type,
            forceLanguageName: forceLanguageName
        )
    }
}
