//
//  PersonalizedToolsType.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum PersonalizedToolsType: Sendable {

    case defaultOrder(language: String)
    case featured(country: String, language: String)
    case ranked(country: String, language: String)
}
