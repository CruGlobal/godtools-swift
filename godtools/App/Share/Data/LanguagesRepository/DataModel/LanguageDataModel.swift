//
//  LanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct LanguageDataModel: Sendable {
    
    let code: BCP47LanguageIdentifier
    let directionString: String
    let id: String
    let name: String
    let type: String
    let forceLanguageName: Bool
}

extension LanguageDataModel: Equatable {
    static func == (this: LanguageDataModel, that: LanguageDataModel) -> Bool {
        return this.id == that.id
    }
}

extension LanguageDataModel {
    
    enum LanguageDirection {
        case leftToRight
        case rightToLeft
    }
    
    var direction: LanguageDataModel.LanguageDirection {
        return directionString == "rtl" ? .rightToLeft : .leftToRight
    }
}
