//
//  PersonalizedLessonsId.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonsId: Sendable {

    let value: String

    init(country: String?, language: String) {

        if let country = country, !country.isEmpty {
            value = "\(country)_\(language)"
        } else {
            value = language
        }
    }
}
