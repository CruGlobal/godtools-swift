//
//  SetLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class SetLocalizationSettingsUseCase {

    private let userLocalizationSettingsRepository: UserLocalizationSettingsRepository

    init(userLocalizationSettingsRepository: UserLocalizationSettingsRepository) {
        self.userLocalizationSettingsRepository = userLocalizationSettingsRepository
    }

    func execute(country: LocalizationSettingsCountryDomainModel) -> AnyPublisher<UserLocalizationSettingsDomainModel, Error> {

        userLocalizationSettingsRepository
            .setCountryPublisher(isoRegionCode: country.isoRegionCode)
            .map { _ in
                return UserLocalizationSettingsDomainModel(
                    selectedCountry: country
                )
            }
            .eraseToAnyPublisher()
    }
}
