//
//  ViewToolSettingsToolLanguagesListUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolSettingsToolLanguagesListUseCase {
    
    private let getInterfaceStringsRepository: GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface
    private let getToolLanguagesRepository: GetToolSettingsToolLanguagesListRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface, getToolLanguagesRepository: GetToolSettingsToolLanguagesListRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getToolLanguagesRepository = getToolLanguagesRepository
    }
    
    func viewPublisher(listType: ToolSettingsToolLanguagesListTypeDomainModel, primaryLanguage: ToolSettingsToolLanguageDomainModel?, parallelLanguage: ToolSettingsToolLanguageDomainModel?, toolId: String, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolSettingsToolLanguagesListDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getToolLanguagesRepository.getToolLanguagesPublisher(listType: listType, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, toolId: toolId, translateInLanguage: appLanguage)
        )
        .map {
            return ViewToolSettingsToolLanguagesListDomainModel(
                interfaceStrings: $0,
                languages: $1
            )
        }
        .eraseToAnyPublisher()
    }
}
