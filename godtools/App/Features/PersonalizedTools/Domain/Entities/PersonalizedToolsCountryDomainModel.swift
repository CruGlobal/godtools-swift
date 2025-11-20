//
//  PersonalizedToolsCountryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolsCountryDomainModel {
    
    let countryNameTranslatedInOwnLanguage: String
    let countryNameTranslatedInCurrentAppLanguage: String
}

extension PersonalizedToolsCountryDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [
            countryNameTranslatedInOwnLanguage,
            countryNameTranslatedInCurrentAppLanguage
        ]
    }
}

extension PersonalizedToolsCountryDomainModel: Identifiable {
    var id: String {
        // TODO: - make this a real value
        return countryNameTranslatedInCurrentAppLanguage
    }
}
