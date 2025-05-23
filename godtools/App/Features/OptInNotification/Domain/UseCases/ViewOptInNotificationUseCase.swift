//
//  ViewOptInNotificationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation

class ViewOptInNotificationUseCase {

    private let getInterfaceStringsRepository: GetOptInNotificationInterfaceStringsRepositoryInterface

    init(getInterfaceStringsRepository: GetOptInNotificationInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }

    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewOptInNotificationDomainModel, Never> {
        
        return self.getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .map { interfaceStrings in
                ViewOptInNotificationDomainModel(interfaceStrings: interfaceStrings)
            }
            .eraseToAnyPublisher()
    }
}
