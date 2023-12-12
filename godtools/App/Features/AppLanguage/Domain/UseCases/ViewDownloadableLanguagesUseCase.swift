//
//  ViewDownloadableLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewDownloadableLanguagesUseCase {
    
    private let getInterfaceStringsRepository: GetDownloadableLanguagesInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetDownloadableLanguagesInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDownloadableLanguagesDomainModel, Never> {
        
        return self.getInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage).map {
            
            return ViewDownloadableLanguagesDomainModel(interfaceStrings: $0)
        }
        .eraseToAnyPublisher()
    }
}
