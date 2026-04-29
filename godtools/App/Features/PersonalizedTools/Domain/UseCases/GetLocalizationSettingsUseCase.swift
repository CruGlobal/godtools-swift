//
//  GetLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLocalizationSettingsUseCase {

    private let userLocalizationSettingsRepository: UserLocalizationSettingsRepository

    init(userLocalizationSettingsRepository: UserLocalizationSettingsRepository) {
        self.userLocalizationSettingsRepository = userLocalizationSettingsRepository
    }

    @MainActor func execute() -> AnyPublisher<UserLocalizationSettingsDomainModel?, Never> {
        
        return userLocalizationSettingsRepository
            .observeCollectionChangesPublisher()
            .flatMap { (settingsChanged: Void) -> AnyPublisher<UserLocalizationSettingsDomainModel?, Never> in
                
                return self.getUserLocalizationSettings()
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserLocalizationSettings() -> AnyPublisher<UserLocalizationSettingsDomainModel?, Never> {
        
        return self.userLocalizationSettingsRepository
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
                    selectedCountry: LocalizationSettingsCountryDomainModel(
                        isoRegionCode: dataModel.selectedCountryIsoRegionCode
                    )
                )
            }
            .eraseToAnyPublisher()
    }
}
