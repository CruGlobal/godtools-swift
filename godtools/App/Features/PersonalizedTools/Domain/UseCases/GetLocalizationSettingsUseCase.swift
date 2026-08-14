//
//  GetLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLocalizationSettingsUseCase: Sendable {

    private let userLocalizationSettingsRepository: UserLocalizationSettingsRepository

    init(userLocalizationSettingsRepository: UserLocalizationSettingsRepository) {
        self.userLocalizationSettingsRepository = userLocalizationSettingsRepository
    }

    @MainActor func execute() -> AnyPublisher<UserLocalizationSettingsDomainModel?, Never> {
        
        return userLocalizationSettingsRepository
            .observeCollectionChangesPublisher()
            .map { _ in
                
                let dataModel: UserLocalizationSettingsDataModel? = self.userLocalizationSettingsRepository.getUserLocalizationSetting()
                
                guard let dataModel = dataModel else {
                    return nil
                }
                
                return UserLocalizationSettingsDomainModel(
                    selectedCountry: LocalizationSettingsCountryDomainModel(
                        isoRegionCode: dataModel.selectedCountryIsoRegionCode
                    )
                )
            }
            .eraseToAnyPublisher()
    }
}
