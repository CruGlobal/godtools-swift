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
    
    init(getInterfaceStringsRepository: GetFavoritesInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewFavoritesDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .map {
                
                ViewFavoritesDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
