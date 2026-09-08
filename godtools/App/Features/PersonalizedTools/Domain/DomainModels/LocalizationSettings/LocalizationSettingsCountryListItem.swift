//
//  LocalizationSettingsCountryListItem.swift
//  godtools
//
//  Created by Rachael Skeath on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum LocalizationSettingsCountryListItem: Sendable, Identifiable, StringSearchable {

    case country(LocalizationSettingsCountryDomainModel)
    case preferNotToSay(LocalizationSettingsPreferNotToSayDomainModel)

    static let preferNotToSayIsoRegionCode: String = ""

    var id: String {
        switch self {
        case .country(let country):
            return country.isoRegionCode
        case .preferNotToSay:
            return "prefer_not_to_say"
        }
    }

    var primaryText: String {
        switch self {
        case .country(let country):
            return country.countryNameTranslatedInOwnLanguage
        case .preferNotToSay(let preferNotToSay):
            return preferNotToSay.preferNotToSayText
        }
    }

    var secondaryText: String {
        switch self {
        case .country(let country):
            return country.countryNameTranslatedInCurrentAppLanguage
        case .preferNotToSay:
            return ""
        }
    }

    var isoRegionCode: String? {
        switch self {
        case .country(let country):
            return country.isoRegionCode
        case .preferNotToSay:
            return Self.preferNotToSayIsoRegionCode
        }
    }

    var searchableStrings: [String] {
        switch self {
        case .country(let country):
            return [
                country.countryNameTranslatedInOwnLanguage,
                country.countryNameTranslatedInCurrentAppLanguage
            ]
        case .preferNotToSay(let preferNotToSay):
            return [preferNotToSay.preferNotToSayText]
        }
    }

    var countryDomainModel: LocalizationSettingsCountryDomainModel {
        switch self {
        case .country(let country):
            return country
        case .preferNotToSay:
            return LocalizationSettingsCountryDomainModel(
                isoRegionCode: Self.preferNotToSayIsoRegionCode,
                countryNameTranslatedInOwnLanguage: "",
                countryNameTranslatedInCurrentAppLanguage: ""
            )
        }
    }
}
