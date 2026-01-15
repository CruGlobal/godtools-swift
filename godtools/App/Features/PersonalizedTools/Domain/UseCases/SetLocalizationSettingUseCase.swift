//
//  SetLocalizationSettingUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class SetLocalizationSettingUseCase {

    private let userLocalizationSettingRepository: UserLocalizationSettingRepository

    init(userLocalizationSettingRepository: UserLocalizationSettingRepository) {
        self.userLocalizationSettingRepository = userLocalizationSettingRepository
    }

    func execute(countryName: String) -> AnyPublisher<String, Never> {

        userLocalizationSettingRepository.setCountryPublisher(countryName: countryName)
            .eraseToAnyPublisher()
    }
}
