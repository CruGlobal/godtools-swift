//
//  GetLessonsInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsInterfaceStringsUseCase {

    private let getInterfaceStringsRepository: GetLessonsInterfaceStringsRepository

    init(getInterfaceStringsRepository: GetLessonsInterfaceStringsRepository) {

        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }

    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonsInterfaceStringsDomainModel, Never> {

        return getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
