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

    private let getCheckNotificationStatus: GetCheckNotificationStatusInterface
    private let getInterfaceStringsRepository: GetOptInNotificationInterfaceStringsRepositoryInterface

    init(getCheckNotificationStatus: GetCheckNotificationStatusInterface,
        getInterfaceStringsRepository: GetOptInNotificationInterfaceStringsRepositoryInterface) {
        
        self.getCheckNotificationStatus = getCheckNotificationStatus
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }

    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewOptInNotificationDomainModel, Never> {
        
        return getCheckNotificationStatus.permissionStatusPublisher()
            .flatMap { status in
                
                let isInitialPrompt = status == .undetermined
                
                return self.getInterfaceStringsRepository
                    .getStringsPublisher(translateInLanguage: appLanguage)
                    .map { interfaceStrings in
                        ViewOptInNotificationDomainModel(interfaceStrings: interfaceStrings, isInitialPrompt: isInitialPrompt)
                    }
            }
            .eraseToAnyPublisher()
    }
}
