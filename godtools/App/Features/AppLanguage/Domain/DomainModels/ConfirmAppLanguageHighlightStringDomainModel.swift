//
//  ConfirmAppLanguageHighlightStringDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ConfirmAppLanguageHighlightStringDomainModel: Sendable {
    
    let fullText: String
    let highlightText: String
    
    static func emptyStrings() -> ConfirmAppLanguageHighlightStringDomainModel {
        return ConfirmAppLanguageHighlightStringDomainModel(fullText: "", highlightText: "")
    }
}
