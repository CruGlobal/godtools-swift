//
//  ViewFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewFavoritesUseCase {
    
    private let getInterfaceStringsRepository: GetFavoritesInterfaceStringsRepositoryInterface
    private let getFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetFavoritesInterfaceStringsRepositoryInterface, getFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getFavoritedToolsRepository = getFavoritedToolsRepository
    }
    
    @MainActor func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewFavoritesDomainModel, Error> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage).setFailureType(to: Error.self),
            getFavoritedToolsRepository.getToolsPublisher(translateInLanguage: appLanguage, maxCount: 5)
        )
        .map {
            
            ViewFavoritesDomainModel(
                interfaceStrings: $0,
                yourFavoritedTools: $1
            )
        }
        .eraseToAnyPublisher()
    }
}
