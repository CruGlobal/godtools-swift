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
    private let getToolLanguagesRepository: GetToolSettingsToolLanguagesRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface, getToolLanguagesRepository: GetToolSettingsToolLanguagesRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getToolLanguagesRepository = getToolLanguagesRepository
    }
    
    // TODO: Eventually ResourceModel needs to be replaced with a ToolDomainModel. ~Levi
    func viewPublisher(tool: ResourceModel, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolSettingsToolLanguagesListDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getToolLanguagesRepository.getToolLanguagesPublisher(tool: tool, translateInLanguage: appLanguage)
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
