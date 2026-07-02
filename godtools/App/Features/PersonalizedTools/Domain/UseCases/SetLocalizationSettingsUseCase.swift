//
//  SetLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class SetLocalizationSettingsUseCase {

    private let userLocalizationSettingsRepository: UserLocalizationSettingsRepository

    init(userLocalizationSettingsRepository: UserLocalizationSettingsRepository) {
        self.userLocalizationSettingsRepository = userLocalizationSettingsRepository
    }

    func execute(country: LocalizationSettingsCountryDomainModel) async throws -> UserLocalizationSettingsDomainModel {

        try await userLocalizationSettingsRepository.storeUserCountry(isoRegionCode: country.isoRegionCode)
        
        return UserLocalizationSettingsDomainModel(
            selectedCountry: country
        )
    }
}
