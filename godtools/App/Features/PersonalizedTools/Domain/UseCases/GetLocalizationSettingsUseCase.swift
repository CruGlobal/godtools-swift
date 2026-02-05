//
//  GetLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLocalizationSettingsUseCase {

    private let userLocalizationSettingsRepository: UserLocalizationSettingsRepository

    init(userLocalizationSettingsRepository: UserLocalizationSettingsRepository) {
        self.userLocalizationSettingsRepository = userLocalizationSettingsRepository
    }

    func execute() -> AnyPublisher<UserLocalizationSettingsDomainModel?, Never> {

        return userLocalizationSettingsRepository
            .getUserLocalizationSettingPublisher()
            .catch { (error: Error) in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .map { (dataModel: UserLocalizationSettingsDataModel?) in

                guard let dataModel = dataModel else {
                    return nil
                }

                return UserLocalizationSettingsDomainModel(
                    selectedCountry: LocalizationSettingsCountryDomainModel(isoRegionCode: dataModel.selectedCountryIsoRegionCode)
                )
            }
            .eraseToAnyPublisher()
    }
}
