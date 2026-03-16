//
//  LocalizationSettingsCountriesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class LocalizationSettingsCountriesRepository: LocalizationSettingsCountriesRepositoryInterface {

    init() {

    }

    func getCountriesPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LocalizationSettingsCountryDataModel], Never> {

        let appLocale = Locale(identifier: appLanguage)

        let countries = Locale.Region.isoRegions
            .filter { isCountryCode(region: $0) }
            .compactMap { region -> LocalizationSettingsCountryDataModel? in

            let regionLocale = findLocaleId(for: region)

            guard let nameInAppLanguage = appLocale.localizedString(forRegionCode: region.identifier),
                  let nameInOwnLanguage = regionLocale.localizedString(forRegionCode: region.identifier)
            else {
                return nil
            }

            return LocalizationSettingsCountryDataModel(
                isoRegionCode: region.identifier,
                countryNameTranslatedInOwnLanguage: nameInOwnLanguage,
                countryNameTranslatedInCurrentAppLanguage: nameInAppLanguage
            )
        }
        .sorted { $0.countryNameTranslatedInCurrentAppLanguage < $1.countryNameTranslatedInCurrentAppLanguage }

        return Just(countries)
            .eraseToAnyPublisher()
    }
    
    private func isCountryCode(region: Locale.Region) -> Bool {
        return region.identifier.count == 2 && region.identifier.allSatisfy { $0.isUppercase && $0.isLetter }
    }
    
    private func findLocaleId(for region: Locale.Region) -> Locale {
        // format: language_REGION, like ja_JP

        let lowercasedRegion = region.identifier.lowercased()

        let localeWhereLanguageMatchesRegion = "\(lowercasedRegion)_\(region.identifier)"
        if Locale.availableIdentifiers.contains(localeWhereLanguageMatchesRegion) {
            return Locale(identifier: localeWhereLanguageMatchesRegion)
        }

        let allLocalesInRegion = Locale.availableIdentifiers
            .filter { $0.hasSuffix("_\(region.identifier)") }
            .sorted { sortByPreferringFirstLetterMatch($0, $1, region: region) }

        for localeId in allLocalesInRegion {
            let locale = Locale(identifier: localeId)
            if let translation = locale.localizedString(forRegionCode: region.identifier), !translation.isEmpty {
                return locale
            }
        }

        return Locale(identifier: region.identifier)
    }

    private func sortByPreferringFirstLetterMatch(_ first: String, _ second: String, region: Locale.Region) -> Bool {
        let firstMatches = languageCodeStartsWithSameLetterAsRegion(localeIdentifier: first, region: region)
        let secondMatches = languageCodeStartsWithSameLetterAsRegion(localeIdentifier: second, region: region)

        if firstMatches && !secondMatches {
            return true
        }
        if !firstMatches && secondMatches {
            return false
        }

        return first < second
    }

    private func languageCodeStartsWithSameLetterAsRegion(localeIdentifier: String, region: Locale.Region) -> Bool {
        let languageCode = localeIdentifier.split(separator: "_").first.map(String.init) ?? ""
        let regionFirstLetter = region.identifier.lowercased().first
        return languageCode.lowercased().first == regionFirstLetter
    }
}
