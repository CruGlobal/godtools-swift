//
//  ViewOptInNotificationsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation

//here
// Job: retrieving and preparing the necessary data for the notifications sheet view
// Specifically, we need to translate the interface strings
class ViewOptInNotificationsUseCase {

    private let getInterfaceStringsRepository:
        GetOptInNotificationsInterfaceStringsRepositoryInterface

    init(
        getInterfaceStringsRepository:
            GetOptInNotificationsInterfaceStringsRepositoryInterface
    ) {
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    // provide publisher data stream for view layer to react to
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<
        ViewOptInNotificationsDomainModel, Never
    > {

        return getInterfaceStringsRepository.getStringsPublisher(
            translateInLanguage: appLanguage
        ).map {
            ViewOptInNotificationsDomainModel(
                interfaceStrings: $0
            )
        }.eraseToAnyPublisher()

    }
}

//private let getInterfaceStringsRepository: GetFavoritesInterfaceStringsRepositoryInterface
//private let getFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface
//
//init(getInterfaceStringsRepository: GetFavoritesInterfaceStringsRepositoryInterface, getFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface) {
//
//    self.getInterfaceStringsRepository = getInterfaceStringsRepository
//    self.getFavoritedToolsRepository = getFavoritedToolsRepository
//}
//
//func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewFavoritesDomainModel, Never> {
//
//    return Publishers.CombineLatest(
//        getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
//        getFavoritedToolsRepository.getToolsPublisher(translateInLanguage: appLanguage, maxCount: 5)
//    )
//    .map {
//
//        ViewFavoritesDomainModel(
//            interfaceStrings: $0,
//            yourFavoritedTools: $1
//        )
//    }
//    .eraseToAnyPublisher()
//}
//}
