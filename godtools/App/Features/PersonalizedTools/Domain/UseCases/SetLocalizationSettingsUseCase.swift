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

    func execute(isoRegionCode: String) -> AnyPublisher<UserLocalizationSettingsDomainModel, Never> {

        userLocalizationSettingsRepository.setCountryPublisher(isoRegionCode: isoRegionCode)
            .map { return UserLocalizationSettingsDomainModel(selectedCountry: LocalizationSettingsCountryDomainModel(isoRegionCode: $0.selectedCountryIsoRegionCode)) }
            .eraseToAnyPublisher()
    }
}
