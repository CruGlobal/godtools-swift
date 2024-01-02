//
//  ViewToolSettingsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolSettingsUseCase {
    
    private let getInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface
    private let getToolHasTipsRepository: GetToolSettingsToolHasTipsRepositoryInterface
    private let getPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface
    private let getParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface, getToolHasTipsRepository: GetToolSettingsToolHasTipsRepositoryInterface, getPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface, getParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getToolHasTipsRepository = getToolHasTipsRepository
        self.getPrimaryLanguageRepository = getPrimaryLanguageRepository
        self.getParallelLanguageRepository = getParallelLanguageRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel, tool: ResourceModel, toolLanguage: ToolSettingsToolLanguageDomainModel?) -> AnyPublisher<ViewToolSettingsDomainModel, Never> {
        
        return Publishers.CombineLatest4(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getToolHasTipsRepository.getHasTipsPublisher(tool: tool, toolLanguage: toolLanguage),
            getPrimaryLanguageRepository.getLanguagePublisher(translateInLanguage: appLanguage),
            getParallelLanguageRepository.getLanguagePublisher(translateInLanguage: appLanguage)
        )
        .map {
            
            let domainModel = ViewToolSettingsDomainModel(
                interfaceStrings: $0,
                hasTips: $1,
                primaryLanguage: $2,
                parallelLanguage: $3
            )
            
            return domainModel
        }
        .eraseToAnyPublisher()
    }
}
