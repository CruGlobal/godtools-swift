//
//  PersonalizedToolsType.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum PersonalizedToolsType {

    case allRanked(country: String, language: String)
    case defaultOrder(language: String)

    init(country: String?, langauge: String) {

        if let country = country, !country.isEmpty {
            self = .allRanked(country: country, language: langauge)
        }
        else {
            self = .defaultOrder(language: langauge)
        }
    }
}
