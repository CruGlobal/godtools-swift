//
//  ViewConfirmRemoveToolFromFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewConfirmRemoveToolFromFavoritesUseCase {
    
    private let interfaceStringsRepository: GetConfirmRemoveToolFromFavoritesInterfaceStringsRepositoryInterface
    
    init(interfaceStringsRepository: GetConfirmRemoveToolFromFavoritesInterfaceStringsRepositoryInterface) {
        
        self.interfaceStringsRepository = interfaceStringsRepository
    }
    
    func viewPublisher(toolId: String, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewConfirmRemoveToolFromFavoritesDomainModel, Never> {
        
        return interfaceStringsRepository
            .getStringsPublisher(toolId: toolId, translateInLanguage: appLanguage)
            .map {
                return ViewConfirmRemoveToolFromFavoritesDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
