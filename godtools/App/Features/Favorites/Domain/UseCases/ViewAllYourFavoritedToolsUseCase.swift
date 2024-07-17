//
//  ViewAllYourFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewAllYourFavoritedToolsUseCase {
    
    private let getInterfaceStringsRepository: GetAllYourFavoritedToolsInterfaceStringsRepositoryInterface
    private let getFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetAllYourFavoritedToolsInterfaceStringsRepositoryInterface, getFavoritedToolsRepository: GetYourFavoritedToolsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getFavoritedToolsRepository = getFavoritedToolsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewAllYourFavoritedToolsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getFavoritedToolsRepository.getToolsPublisher(translateInLanguage: appLanguage, maxCount: nil)
        )
        .map {
            
            ViewAllYourFavoritedToolsDomainModel(
                interfaceStrings: $0,
                yourFavoritedTools: $1
            )
        }
        .eraseToAnyPublisher()
    }
}
