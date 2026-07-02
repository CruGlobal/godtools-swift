//
//  SetLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class SetLocalizationSettingsUseCase {

    private let userLocalizationSettingsRepository: UserLocalizationSettingsRepository

    init(userLocalizationSettingsRepository: UserLocalizationSettingsRepository) {
        self.userLocalizationSettingsRepository = userLocalizationSettingsRepository
    }

    func execute(country: LocalizationSettingsCountryDomainModel) -> AnyPublisher<UserLocalizationSettingsDomainModel, Error> {

        Task {
            try await userLocalizationSettingsRepository.storeUserCountry(isoRegionCode: country.isoRegionCode)
        }
        
        let domainModel = UserLocalizationSettingsDomainModel(
            selectedCountry: country
        )
        
        return Just(domainModel)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
